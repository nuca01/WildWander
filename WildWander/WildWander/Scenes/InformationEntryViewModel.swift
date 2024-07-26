//
//  InformationEntryViewModel.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation
import NetworkingService

class InformationEntryViewModel {
    //MARK: - Properties
    private var email: String
    private let genders = ["Male", "Female"]
    private var endPointCreator = EndPointCreator(path: "/api/User/RegisterUser", method: "Post", accessToken: "")
    
    private lazy var inputDateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var dateOfBirth: String = ""
    
    var genderCount: Int {
        genders.count
    }
    
    var didTryToRegister: ((_: String?) -> Void)?
    
    //MARK: - Initializers
    init(email: String) {
        self.email = email
    }
    
    //MARK: - Methods
    func genderFor(index: Int) -> String {
        genders[index]
    }
    
    func formatted(date: Date) -> String {
        dateOfBirth = inputDateFormatter.string(from: date)
        return inputDateFormatter.string(from: date)
    }
    
    func register(
        password: String,
        firstName: String,
        lastName: String,
        gender: String
    ) {
        if !passwordIsValid(password) { return }
        
        if !textFieldsAreNotEmpty(
            firstName: firstName, 
            lastName: lastName,
            gender: gender
        ) { return }
        
        configureEndPoint(
            password: password,
            firstName: firstName,
            lastName: lastName,
            gender: gender
        )
        
        sendPostRequest()
    }
    
    private func passwordIsValid(_ password: String) -> Bool {
        let passwordRegex = ".*\\d.*"
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            
        guard password.count >= 6,
              passwordPredicate.evaluate(with: password) else {
            didTryToRegister?("Password must contain a digit and at least 6 characters")
            return false
        }
        
        return true
    }
    
    private func textFieldsAreNotEmpty(
        firstName: String,
        lastName: String,
        gender: String
    ) -> Bool {
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !gender.isEmpty,
              !dateOfBirth.isEmpty else {
            didTryToRegister?("all fields are required")
            return false
        }
        return true
    }
    
    private func configureEndPoint(
        password: String,
        firstName: String,
        lastName: String,
        gender: String
    ) {
        let userInformation = RegisterUserInformation(
            password: password,
            email: email,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender == "Male" ? 1: 2
        )
        
        endPointCreator.body = userInformation
    }
    
    private func sendPostRequest() {
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Token, NetworkError>) in
            switch result {
            case .success(let response):
                let successfullySaved = KeychainHelper.save(token: response.token, forKey: "authorizationToken")
                if successfullySaved {
                    self?.didTryToRegister?(nil)
                } else {
                    self?.didTryToRegister?("error during logging in")
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
                self?.didTryToRegister?(message)
            }
        }
    }
}
