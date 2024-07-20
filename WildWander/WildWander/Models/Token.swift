//
//  Token.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation

class Token: Decodable {
    var token: String
    
    init(token: String) {
        self.token = token
    }
}
