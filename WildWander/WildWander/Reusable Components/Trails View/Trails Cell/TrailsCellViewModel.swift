//
//  TrailsCellViewModel.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation
import NetworkingService

class TrailsCellViewModel {
    private lazy var token = KeychainHelper.retrieveToken(forKey: "authorizationToken")
    
    private lazy var endPointCreator = EndPointCreator(path: "/api/Trail/SaveTrail", method: "POST", accessToken: token ?? "")
    
    var isSignedIn: Bool {
        token == nil ? false: true
    }
    
    var errorDidHappen: ((_: String) -> Void)?
    
    func save(saveTrailModel: SaveTrail) {
        endPointCreator.body = saveTrailModel
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Bool, NetworkError>) in
            switch result {
            case .success(_): break
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode: break
                case .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                case .noInternetConnection:
                    message = "it seems like you are not connected to internet"
                }
                self?.errorDidHappen?(message)
            }
        }
    }
}
