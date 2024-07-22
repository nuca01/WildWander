//
//  SaveTrail.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation

class SaveTrail: Encodable {
    var name: String?
    var description: String?
    var savedListId: Int?
    var trailId: Int
    
    init(name: String? = nil, description: String? = nil, savedListId: Int? = nil, trailId: Int) {
        self.name = name
        self.description = description
        self.savedListId = savedListId
        self.trailId = trailId
    }
}
