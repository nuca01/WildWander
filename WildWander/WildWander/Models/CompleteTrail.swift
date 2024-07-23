//
//  CompleteTrail.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation

struct CompleteTrail: Codable {
    var trailId: Int?
    var length: Int
    var time: Int
    var routeGeometry: String?
    var elevationGain: Int
}
