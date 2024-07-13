//
//  TrailsViewViewModel.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import Foundation
import NetworkingService

class TrailsViewViewModel {
    private var trails: [Trail] = []
    private let endPointCreator = EndPointCreator(path: "/api/trail/gettrails", method: "GET", accessToken: "")
    
    var trailCount: Int {
        trails.count
    }
    
    func trailOf(index: Int) -> Trail {
        trails[index]
    }
    
    func generateURL(from string: String) -> URL? {
        return URL(string: string)
    }
    
    var trailsDidChange: (() -> Void)?
    
    func changeTrails(to trails: [Trail]) {
        self.trails = trails
        trailsDidChange?()
    }
}
