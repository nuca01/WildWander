//
//  Trail.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import Foundation

struct Trail: Codable, Identifiable {
    var id: Int?
    var routeIdentifier: String?
    var length: Double?
    var elevationGain: Int?
    var description: String?
    var routeGeometry: String?
    var address: String?
    var rating: Double?
    var difficulty: String?
    var images: [String]?
    var staticMapImage: String?
    var startLatitude: Double?
    var startLongitude: Double?
    var isSaved: Bool?
    var isCompleted: Bool?
}

struct TrailContainer: Decodable {
    var totalCount: Int?
    var items: [Trail]?
}
