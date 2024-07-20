//
//  emailValidation.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation

class EmailValidation: Encodable {
    var email: String
    
    init(email: String) {
        self.email = email
    }
}
