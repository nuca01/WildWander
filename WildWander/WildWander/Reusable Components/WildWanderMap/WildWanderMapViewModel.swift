//
//  WildWanderMapViewModel.swift
//  WildWander
//
//  Created by nuca on 11.07.24.
//

import Foundation
import CoreLocation

final class WildWanderMapViewModel {
    private let view: WildWanderMapView
    private let locationManager = CLLocationManager()
    var activeAnnotationsId: String = ""
    var customTrailPolyline: String?
    
    var userLocationIsEnabled: Bool {
        let authorizationStatus = locationManager.authorizationStatus
        if (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            return true
        } else {
            return false
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    init(view: WildWanderMapView) {
        self.view = view
        view.willAccessUsersLocation = startUpdatingLocation
    }
}
