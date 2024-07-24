//
//  UserDetails.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation

struct UserDetails: Codable {
    var firstName: String?
    var lastName: String?
    var imgUrl: String?
    var dateOfBirth: String?
    var gender: Int?
    var completedTrailCount: Int?
    var completedLength: Int?
}
