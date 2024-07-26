//
//  ProfilePageViewModel.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation
import NetworkingService

final class ProfilePageViewModel: ObservableObject {
    //MARK: - Properties
    private var token: String? {
        KeychainHelper.retrieveToken(forKey: "authorizationToken")
    }
    
    var userLoggedIn: Bool {
        token == nil ? false: true
    }
    
    var currentYear: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: date)
        return currentYear
    }
    
    private var userDetailsEndPointCreator: EndPointCreator?
    private var completedTrailsEndPointCreator: EndPointCreator?
    
    @Published var userDetails: UserDetails?
    @Published var completedTrails: [CompletedTrail]?
    
    var didLogOut: (() -> Void)?
    //MARK: - Initializer
    init() {
        userDetailsEndPointCreator = EndPointCreator(path: "/api/User/GetUserDetails", method: "GET", accessToken: token ?? "")
        completedTrailsEndPointCreator = EndPointCreator(path: "/api/Trail/GetCompletedTrails", method: "GET", accessToken: token ?? "")
    }
    
    //MARK: - Methods
    func getUserInformation() {
        getUserDetails()
        getCompletedTrails()
    }
    
    private func getUserDetails() {
        NetworkingService.shared.sendRequest(endpoint: userDetailsEndPointCreator!) { [weak self] (result: Result<UserDetails, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let responseModel):
                saveUserDetailsLocally(responseModel)
                DispatchQueue.main.async { [weak self] in
                    self?.userDetails = responseModel
                }
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode:
                    message = "decode error has occurred"
                case .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                case .noInternetConnection:
                    message = "it seems like you are not connected to internet"
                }
                print(message)
            }
        }
    }
    
    private func getCompletedTrails() {
        NetworkingService.shared.sendRequest(endpoint: completedTrailsEndPointCreator!) { [weak self] (result: Result<CompletedTrailsList, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let responseModel):
                DispatchQueue.main.async { [weak self] in
                    self?.completedTrails = responseModel.items
                }
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode:
                    message = "decode error has occurred"
                case .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                case .noInternetConnection:
                    message = "it seems like you are not connected to internet"
                }
                print(message)
            }
        }
    }
    
    func updateLogInStatus() {
        userDetailsEndPointCreator?.changeAccessToken(accessToken: token)
        completedTrailsEndPointCreator?.changeAccessToken(accessToken: token)
    }
    
    func logOut() {
        deleteProfileData()
        userDetails = nil
        _ = KeychainHelper.deleteToken(forKey: "authorizationToken")
        updateLogInStatus()
        didLogOut?()
    }
    
    private func saveUserDetailsLocally(_ userDetails: UserDetails) {
        if let encodedData = try? JSONEncoder().encode(userDetails) {
            UserDefaults.standard.set(encodedData, forKey: "userDetails")
        }
    }
    
    func loadUserDetailsFromLocal() {
        if let savedData = UserDefaults.standard.data(forKey: "userDetails"),
           let profileData = try? JSONDecoder().decode(UserDetails.self, from: savedData) {
            userDetails = profileData
        }
    }
    
    func deleteProfileData() {
        UserDefaults.standard.removeObject(forKey: "userDetails")
    }
    
    func userDetailsLengthInKilometres() -> Int {
        (userDetails?.completedLength ?? 0) / 1000
    }
    
    func metresToKilometresInString(_ metres: Int) -> String {
        let kilometres = Double(metres) / 1000.0
        let formattedDouble = String(format: "%.1f", kilometres)
        return "\(formattedDouble)km"
    }
    
    func generateURL(from string: String) -> URL? {
        return URL(string: string)
    }
}
