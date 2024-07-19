//
//  EmailEntryViewModel.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation
import NetworkingService

class EmailEntryViewModel {
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private var endPointCreator = EndPointCreator(path: "/api/User/RegisterUserEmail", method: "Post", accessToken: "")
    
    func sendCodeTo(_ email: String, completion: @escaping (String?) -> Void) {
        if isValidEmail(email: email) {
            endPointCreator.body = email.data(using: .utf8)
            
            NetworkingService.shared.sendRequest(endpoint: endPointCreator) { (result: Result<TrailContainer, NetworkError>) in
                switch result {
                case .success(_):
                    completion(nil)
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
        } else {
            completion("Email format is invalid")
        }
    }
}
