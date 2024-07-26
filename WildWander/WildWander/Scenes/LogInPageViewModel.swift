//
//  LogInPageViewModel.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation
import NetworkingService

class LogInPageViewModel {
    //MARK: - Properties
    private var email: String?
    private var password: String?
    
    private var endPointCreator = EndPointCreator(path: "/api/User/Login", method: "GET", accessToken: "")
    var didTryToLogIn: ((_: String?) -> Void)?
    
    //MARK: - Methods
    
    private func configureEndPointCreator() {
        let queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        endPointCreator.queryItems = queryItems
    }
    
    func logIn(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            didTryToLogIn?("all fields should be filled in")
            return
        }
        
        self.email = email
        self.password = password
        
        configureEndPointCreator()
        
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Token, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                let successfullySaved = KeychainHelper.save(token: responseModel.token, forKey: "authorizationToken")
                if successfullySaved {
                    didTryToLogIn?(nil)
                } else {
                    didTryToLogIn?("error during logging in")
                }
                
            case .failure(let error):
                var message = ""
                switch error {
                case .unknown:
                    message = "unknown error has occurred"
                case .decode, .invalidURL:
                    message = "internal error has occurred"
                case .unexpectedStatusCode(let errorDescription):
                    message = errorDescription
                case .noInternetConnection:
                    message = "it seems like you are not connected to internet"
                }
                didTryToLogIn?(message)
            }
        }
    }
}
