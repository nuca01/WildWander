//
//  MapView.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import Foundation
import MapboxMaps

final class WildWanderMapView: UIView {
    private lazy var mapView: MapView = {
        let options = MapInitOptions(cameraOptions: cameraOptions)
        let mapView = MapView(frame: bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.loadStyleURI(.outdoors)
        mapView.ornaments.options.scaleBar.visibility = .visible
        return mapView
    }()
    
    var cameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(latitude: 41.879, longitude: -87.635),
        zoom: 16,
        bearing: 12,
        pitch: 0
    ) {
        didSet {
            mapView.mapboxMap.setCamera(to: cameraOptions)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    private func setUpView() {
        addSubview(mapView)
    }
}
