//
//  WildWanderMapView.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import UIKit
import MapboxMaps

protocol WildWanderMapViewDelegate {
    func mapStyleButtonTapped(currentMapStyle: StyleURI)
}

final class WildWanderMapView: UIView {
    //MARK: - Properties
    private lazy var mapView: MapView = {
        let options = MapInitOptions(cameraOptions: cameraOptions)
        let mapView = MapView(frame: bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.loadStyleURI(mapStyle)
        mapView.ornaments.options.scaleBar.visibility = .visible
        return mapView
    }()
    
    var mapStyle: StyleURI = .outdoors
    {
        didSet {
            mapView.mapboxMap.loadStyleURI(mapStyle)
        }
    }
    
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
    
    private lazy var mapStyleButton: UIButton = {
        let uiButton = UIButton()
        uiButton.setImage(UIImage(named: "mapStyle"), for: .normal)
        uiButton.addAction(
            UIAction { [weak self] _ in
                self?.delegate?.mapStyleButtonTapped(currentMapStyle: self?.mapStyle ?? .outdoors)
            }, for: .touchUpInside
        )
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        uiButton.isUserInteractionEnabled = true
        return uiButton
    }()
    
    var delegate: WildWanderMapViewDelegate?
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    //MARK: - Methods
    private func setUpViews() {
        addSubview(mapView)
        addSubview(mapStyleButton)
        constrainMapStyleButton()
    }
    
    private func constrainMapStyleButton() {
        NSLayoutConstraint.activate([
            mapStyleButton.heightAnchor.constraint(equalToConstant: 52),
            mapStyleButton.widthAnchor.constraint(equalToConstant: 52),
            mapStyleButton.topAnchor.constraint(equalTo: topAnchor, constant: bounds.height / 4),
            mapStyleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
