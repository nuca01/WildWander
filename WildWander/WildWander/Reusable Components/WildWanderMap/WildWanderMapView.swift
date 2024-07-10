//
//  WildWanderMapView.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import UIKit
import MapboxMaps

protocol WildWanderMapViewDelegate: AnyObject {
    func mapStyleButtonTapped(currentMapStyle: StyleURI)
}

final class WildWanderMapView: UIView {
    //MARK: - Properties
    weak var delegate: WildWanderMapViewDelegate?
    var viewModel: WildWanderMapViewModel?
    var willAccessUsersLocation: (() -> Void)?
    let alert = WildWanderAlertView(
        title: "share your location",
        message: "in order to access your location you need to grant app the location permission",
        firstButtonTitle: "Go To Settings",
        dismissButtonTitle: "Maybe Later"
    )
    
    private lazy var mapView: MapView = {
        let randomLocation = CLLocationCoordinate2D(latitude: 41.879, longitude: -87.635)
        let cameraOptions = CameraOptions(
            center: randomLocation,
            zoom: 16,
            bearing: 12,
            pitch: 0
        )
        let options = MapInitOptions(cameraOptions: cameraOptions)
        
        let mapView = MapView(frame: bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.loadStyleURI(mapStyle)
        mapView.ornaments.options.scaleBar.visibility = .visible
        mapView.location.options.puckType = .puck2D(Puck2DConfiguration())
        
        return mapView
    }()
    
    var mapStyle: StyleURI = .outdoors
    {
        didSet {
            if mapStyle != .outdoors && mapStyle != .satellite {
                mapStyle = .outdoors
            } else {
                mapView.mapboxMap.loadStyleURI(mapStyle)
            }
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
    
    private lazy var userLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "userLocation"), for: .normal)
        button.addAction(
            UIAction { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel!.userLocationIsEnabled {
                    self.centerMapOnUserLocation()
                } else {
                    self.showLocationDisabledAlert()
                }
            }, for: .touchUpInside
        )
        
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            mapStyleButton,
            userLocationButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = WildWanderMapViewModel(view: self)
        setUpViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewModel = WildWanderMapViewModel(view: self)
        setUpViews()
    }
    
    //MARK: - LifeCycle
    func didLoad() {
        if viewModel!.userLocationIsEnabled {
            centerMapOnUserLocation()
        }
    }
    
    //MARK: - SetUpViews
    private func setUpViews() {
        addSubview(mapView)
        addSubview(buttonsStackView)
        constrainButtons()
        constrainButtonsStackView()
    }
    
    private func constrainButtons() {
        buttonsStackView.subviews.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 52),
                button.widthAnchor.constraint(equalToConstant: 52),
            ])
        }
    }
    
    private func constrainButtonsStackView() {
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: bounds.height / 4),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    //MARK: - Helper Methods
    private func changeCameraOptions(
        center: CLLocationCoordinate2D? = nil,
        padding: UIEdgeInsets? = nil,
        anchor: CGPoint? = nil,
        zoom: CGFloat? = nil,
        bearing: CLLocationDirection? = nil,
        pitch: CGFloat? = nil
    ) {
        mapView.camera.ease(to: CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch
        ), duration: 1.0)
    }
    
    private func centerMapOnUserLocation() {
        willAccessUsersLocation?()
        guard let location = mapView.location.latestLocation else { return }
        changeCameraOptions(center: location.coordinate, zoom: 16)
    }
    
    private func showLocationDisabledAlert() {
        alert.onFirstButtonTapped = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.show(in: self)
    }
}
