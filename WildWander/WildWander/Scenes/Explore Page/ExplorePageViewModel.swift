//
//  ExplorePageViewModel.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import Foundation
import NetworkingService

class ExplorePageViewModel {
    private var trails: [Trail] = []
    private var endPointCreator = EndPointCreator(path: "/api/trail/gettrails", method: "GET", accessToken: "")
    var trailsDidChange: ((_: [Trail]) -> Void)?
    
    init(viewController: ExplorePageViewController, currentBounds: Bounds) {
        configureClosureDidChangeMapBounds(for: viewController)
        getTrailsWith(bounds: currentBounds)
    }
    
    private func configureClosureDidChangeMapBounds(for viewController: ExplorePageViewController) {
        viewController.didChangeMapBounds = { [weak self] upperLongitude, upperLatitude, lowerLongitude, lowerLatitude in
            
            let bounds = Bounds(
                upperLongitude: upperLongitude,
                upperLatitude: upperLatitude,
                lowerLongitude: lowerLongitude,
                lowerLatitude: lowerLatitude
            )
            
            self?.getTrailsWith(bounds: bounds)
        }
    }
    
    private func getTrailsWith(bounds: Bounds) {
        configureEndPointCreator(bounds: bounds)
        
        getTrails()
    }
    
    private func configureEndPointCreator(bounds: Bounds) {
        let queryItems = [
            URLQueryItem(name: "UpperLongitude", value: "\(bounds.upperLongitude)"),
            URLQueryItem(name: "UpperLatitude", value: "\(bounds.upperLatitude)"),
            URLQueryItem(name: "LowerLongitude", value: "\(bounds.lowerLongitude)"),
            URLQueryItem(name: "LowerLatitude", value: "\(bounds.lowerLatitude)")
        ]
        
        endPointCreator.queryItems = queryItems
    }
    
    private func getTrails() {
        NetworkingService.shared.sendRequest(endpoint: endPointCreator) { [weak self] (result: Result<TrailContainer, NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseModel):
                self.trails = responseModel.items ?? []
                self.trailsDidChange?(trails)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
