//
//  RegisterUserInformation.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation

class RegisterUserInformation: Encodable {
    var password: String
    var email: String
    var firstName: String
    var lastName: String
    var dateOfBirth: String
    var gender: Int
    
    init(password: String, email: String, firstName: String, lastName: String, dateOfBirth: String, gender: Int) {
        self.password = password
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
    }
}
