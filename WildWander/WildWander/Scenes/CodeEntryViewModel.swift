//
//  CodeEntryViewModel.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation
import NetworkingService

class CodeEntryViewModel {
    //MARK: - Properties
    private var email: String
    private var code: String = "....."
    private var codeIsValid: Bool {
        !code.contains(".")
    }
    private var endPointCreator = EndPointCreator(path: "/api/User/ValidateUserCode", method: "GET", accessToken: "")
    
    //MARK: - Initializer
    init(email: String) {
        self.email = email
    }
    
    //MARK: - Methods
    func ChangeCodeNumber(for index: Int, with number: String) {
        guard index >= 0 && index < code.count else { return }
        var codeArray = Array(code)
        
        if number.isEmpty {
            codeArray[index] = "."
        } else {
            codeArray[index] = Character(number)
        }
        
        code = String(codeArray)
    }
    
    private func configureEndPointCreator() {
        let queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "code", value: code)
        ]
        
        endPointCreator.queryItems = queryItems
    }
    
    func validate() {
        if codeIsValid {
            configureEndPointCreator()
            NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<Bool, NetworkError>) in
                guard let self else { return }
                
                switch result {
                case .success(let responseModel): break
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
}
