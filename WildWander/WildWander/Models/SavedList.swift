//
//  SavedList.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation

class SavedList: Decodable {
    var id: Int
    var name: String?
    var description: String?
    var savedTrailCount: Int?
    var imageUrl: String?
}

class AllSavedList: Decodable {
    var items: [SavedList]?
}
