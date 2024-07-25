//
//  CompletedTrail.swift
//  WildWander
//
//  Created by nuca on 25.07.24.
//

import Foundation

struct CompletedTrail: Decodable, Identifiable {
    var id: Int
    var name: String?
    var trailId: Int?
    var length: Int?
    var elevationGain: Int?
    var time: String?
    var date: String?
    var staticImage: String?
}

struct CompletedTrailsList: Decodable {
    var totalCount: Int?
    var items: [CompletedTrail]?
}
