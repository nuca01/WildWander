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
    
    private var endPointCreator: EndPointCreator?
    
    @Published var userDetails: UserDetails?
    
    var didLogOut: (() -> Void)?
    //MARK: - Initializer
    init() {
        endPointCreator = EndPointCreator(path: "/api/User/GetUserDetails", method: "GET", accessToken: token ?? "")
    }
    
    //MARK: - Methods
    func getUserInformation() {
        NetworkingService.shared.sendRequest(endpoint: endPointCreator!) { [weak self] (result: Result<UserDetails, NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let responseModel):
                DispatchQueue.main.async { [weak self] in
                    self?.saveUserDetailsLocally(responseModel)
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
                }
                print(message)
            }
        }
    }
    
    func updateLogInStatus() {
        endPointCreator!.changeAccessToken(accessToken: token)
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
        UserDefaults.standard.removeObject(forKey: "profileData")
    }
}
