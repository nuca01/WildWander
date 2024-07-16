//
//  Location.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import Foundation

class Location: Decodable {
    var displayName: String?
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case latitude = "lat"
        case longitude = "lon"
    }
}
