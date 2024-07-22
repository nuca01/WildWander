//
//  CreateList.swift
//  WildWander
//
//  Created by nuca on 22.07.24.
//

import Foundation

class CreateList: Encodable {
    var name: String
    var description: String?
    
    init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}
