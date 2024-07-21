//
//  TrailsCellViewModel.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation
import NetworkingService

class TrailsCellViewModel {
    private var endPointCreator = {
        let token = KeychainHelper.retrieveToken(forKey: "authorizationToken")
        
        let endPointCreator = EndPointCreator(path: "/api/Trail/SaveTrail", method: "POST", accessToken: token ?? "")
        
        return endPointCreator
    }()
    
    var errorDidHappen: ((_: String) -> Void)?
    
    func save(saveTrailModel: SaveTrail) {
        endPointCreator.body = saveTrailModel
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Int, NetworkError>) in
            switch result {
            case .success(_): break
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode, .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                }
                self?.errorDidHappen?(message)
            }
        }
    }
}
