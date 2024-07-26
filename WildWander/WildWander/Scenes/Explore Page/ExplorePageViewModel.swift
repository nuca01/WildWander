//
//  ExplorePageViewModel.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import Foundation
import NetworkingService

class ExplorePageViewModel {
    //MARK: - Properties
    private var trails: [Trail] = []
    
    private var token: String? {
        KeychainHelper.retrieveToken(forKey: "authorizationToken")
    }
    
    private lazy var endPointCreator = EndPointCreator(path: "/api/trail/gettrails", method: "GET", accessToken: token ?? "")
    
    var trailsDidChange: ((_: [Trail]) -> Void)?
    var errorDidHappen: ((_: String, _: String) -> Void)?
    
    //MARK: - Initializer
    init(currentBounds: Bounds) {
        getTrailsWith(bounds: currentBounds)
    }
    
    //MARK: - Methods
    func getTrailsWith(bounds: Bounds) {
        configureEndPointCreator(bounds: bounds)
        
        getTrails()
    }
    
    private func configureEndPointCreator(bounds: Bounds) {
        let queryItems = [
            URLQueryItem(name: "UpperLongitude", value: "\(bounds.upperLongitude)"),
            URLQueryItem(name: "UpperLatitude", value: "\(bounds.upperLatitude)"),
            URLQueryItem(name: "LowerLongitude", value: "\(bounds.lowerLongitude)"),
            URLQueryItem(name: "LowerLatitude", value: "\(bounds.lowerLatitude)")
        ]
        
        endPointCreator.queryItems = queryItems
    }
    
    private func getTrails() {
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<TrailContainer, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                self.trails = responseModel.items ?? []
                self.trailsDidChange?(trails)
            case .failure(let error):
                switch error {
                case .noInternetConnection:
                    errorDidHappen?("oops can't connect to the internet", "it seems like you have connection issues")
                default:
                    errorDidHappen?("error has occurred", "internal error has occurred try later")
                }
            }
        }
    }
    
    func updateLogInStatus() {
        endPointCreator.changeAccessToken(accessToken: token)
    }
}
