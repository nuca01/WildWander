//
//  EmailEntryViewModel.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation
import NetworkingService

class EmailEntryViewModel {
    private var endPointCreator = EndPointCreator(path: "/api/User/RegisterUserEmail", method: "POST", accessToken: "")
    var didSendAnEmail: ((_: String?) -> Void)?
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func sendCodeTo(_ email: String) {
        if isValidEmail(email: email) {
            let emailValidationModel: EmailValidation = EmailValidation(email: email)
            
            endPointCreator.body = emailValidationModel
            
            NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Int, NetworkError>) in
                switch result {
                case .success(_):
                    self?.didSendAnEmail?(nil)
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
                    self?.didSendAnEmail?(message)
                }
            }
        } else {
            didSendAnEmail?("Email format is invalid")
        }
    }
}
