//
//  TrailDetails.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation

struct TrailDetails: Codable {
    var id: Int?
    var length: Double?
    var elevationGain: Int?
    var address: String?
    var difficulty: String?
    var time: Int?
    var routeGeometry: String?
    var isSaved: Bool?
    var isCompleted: Bool?
}
