//
//  WildWanderMapView.swift
//  WildWander
//
//  Created by nuca on 02.07.24.
//

import UIKit
import MapboxMaps
import MapboxNavigation
import MapboxDirections
import MapboxCoreNavigation

protocol WildWanderMapViewDelegate: AnyObject {
    func mapStyleButtonTapped(currentMapStyle: StyleURI)
}

final class WildWanderMapView: UIView {
    //MARK: - Properties
    weak var delegate: WildWanderMapViewDelegate?
    var viewModel: WildWanderMapViewModel?
    var willAccessUsersLocation: (() -> Void)?
    var didTapOnAnnotation: ((_: PointAnnotation?) -> Void)?
    let locationDisabledAlert = WildWanderAlertView(
        title: "share your location",
        message: "in order to access your location you need to grant app the location permission",
        firstButtonTitle: "Go To Settings",
        dismissButtonTitle: "Maybe Later"
    )
    private var pointAnnotationManager: PointAnnotationManager?
    var allowsDynamicPointAnnotations: Bool = false
    private var annotations: [PointAnnotation] = []
    
    private lazy var mapView: NavigationMapView = {
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
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        
        mapView.location.options.puckType = .puck2D(configuration)
        
        return NavigationMapView(frame: bounds, mapView: mapView)
    }()
    
    var mapStyle: StyleURI = .outdoors
    {
        didSet {
            if mapStyle != .outdoors && mapStyle != .satellite {
                mapStyle = .outdoors
            } else {
                mapView.mapView.mapboxMap.loadStyleURI(mapStyle)
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
    
    convenience init(frame: CGRect, allowsDynamicPointAnnotations: Bool) {
        self.init(frame: frame)
        self.allowsDynamicPointAnnotations = allowsDynamicPointAnnotations
        pointAnnotationManager = mapView.mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager?.delegate = self
        setupAnnotationsIcons()
        setupDynamicAnnotationsGesture()
    }
    
    convenience init(
        frame: CGRect,
        allowsStaticPointAnnotations: Bool,
        coordinates: [CLLocationCoordinate2D]
    ) {
        self.init(frame: frame)
        
        if allowsStaticPointAnnotations {
            pointAnnotationManager = mapView.mapView.annotations.makePointAnnotationManager()
            pointAnnotationManager?.delegate = self
            setupAnnotationsIcons()
        }
        
        pointAnnotationManager?.annotations = coordinates.map { coordinate in
            PointAnnotation(coordinate: coordinate)
        }
        drawRoute()
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
        mapView.mapView.camera.ease(to: CameraOptions(
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
        guard let location = mapView.mapView.location.latestLocation else { return }
        changeCameraOptions(center: location.coordinate, zoom: 16)
    }
    
    private func showLocationDisabledAlert() {
        locationDisabledAlert.onFirstButtonTapped = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        locationDisabledAlert.show(in: self)
    }
}

//MARK: - Annotations
extension WildWanderMapView: AnnotationInteractionDelegate {
    func annotationManager(_ manager: any MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [any MapboxMaps.Annotation]) {
        let annotationTapped = pointAnnotationManager!.annotations.first(where: { value in
            value.id == annotations.last?.id
        })
        
        didTapOnAnnotation?(annotationTapped)
    }
    
    private func setupAnnotationsIcons() {
        try? mapView.mapView.mapboxMap.style.addImage(UIImage(named: "redMarker")!, id: "redMarker")
        try? mapView.mapView.mapboxMap.style.addImage(UIImage(named: "blueMarker")!, id: "blueMarker")
    }
    
    private func setupDynamicAnnotationsGesture() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func changeActiveAnnotationIndex(to index: Int) -> Bool {
        if allowsDynamicPointAnnotations {
            let arrayCount = self.annotations.count
            
            if index > arrayCount {
                return false
            }
            
            changeOldActiveAnnotationMarker()
            
            if index == arrayCount {
                viewModel?.activeAnnotationsId = ""
            } else {
                changeMarkerOfFutureActiveAnnotation(of: index)
                viewModel?.activeAnnotationsId = self.annotations[index].id
            }
            return true
        }
        return false
    }
    
    private func changeOldActiveAnnotationMarker() {
        if let activeAnnotationsId = viewModel?.activeAnnotationsId
        {
            pointAnnotationManager?.annotations = pointAnnotationManager!.annotations.map({ annotation in
                var newAnnotation = annotation
                if annotation.id == activeAnnotationsId  {
                    newAnnotation.iconImage = "blueMarker"
                }
                return newAnnotation
            })
        }
    }
    
    private func changeMarkerOfFutureActiveAnnotation(of index: Int) {
        pointAnnotationManager?.annotations = pointAnnotationManager!.annotations.map({ annotation in
            var newAnnotation = annotation
            if annotation.id == self.annotations[index].id  {
                newAnnotation.iconImage = "redMarker"
            }
            return newAnnotation
        })
    }
    
    func deleteAnnotationOf(index: Int) -> Int? {
        if allowsDynamicPointAnnotations {
            let annotationsCount = annotations.count
            if index > annotationsCount {
                return nil
            } else if index == annotationsCount {
                changeToFutureActiveAnnotation()
                return self.annotations.firstIndex { value in
                    value.id == viewModel?.activeAnnotationsId
                }
            }
            
            if annotationsCount > 1 {
                changeToFutureActiveAnnotation()
            }
            
            removeAnnotationEverywhere(of: self.annotations[index].id)
            
            return self.annotations.firstIndex { value in
                value.id == viewModel?.activeAnnotationsId
            }
        }
        return nil
    }
    
    private func removeAnnotationEverywhere(of id: String) {
        pointAnnotationManager?.annotations.removeAll(where: { annotation in
            annotation.id == id
        })
        
        self.annotations.removeAll (where: { annotation in
            annotation.id == id
        })
    }
    
    private func changeToFutureActiveAnnotation() {
        var futureActiveAnnotationFound = false
        pointAnnotationManager?.annotations = pointAnnotationManager!.annotations.map({ annotation in
            var newAnnotation = annotation
            if annotation.id != viewModel?.activeAnnotationsId && !futureActiveAnnotationFound {
                viewModel?.activeAnnotationsId = newAnnotation.id
                newAnnotation.iconImage = "redMarker"
                futureActiveAnnotationFound = true
            }
            return newAnnotation
        })
    }
    
    private func longPressBegan(at location: CGPoint) {
        let coordinate = mapView.mapView.mapboxMap.coordinate(for: location)
        
        var annotation = PointAnnotation(point: Point(coordinate))
        annotation.iconImage = "redMarker"
        appendAnnotationsArray(with: annotation)
    }
    
    private func appendAnnotationsArray(with annotation: PointAnnotation) {
        if let activeAnnotationId = viewModel?.activeAnnotationsId, let pointAnnotationManager, activeAnnotationExists(in: pointAnnotationManager)
        {
            pointAnnotationManager.annotations = renewedAnnotations(in: pointAnnotationManager, with: annotation)
            let currentActiveAnnotationIndexInContainer = self.annotations.firstIndex { value in
                value.id == viewModel?.activeAnnotationsId
            }
            
            self.annotations[currentActiveAnnotationIndexInContainer!] = annotation
            viewModel?.activeAnnotationsId = annotation.id
        } else {
            viewModel?.activeAnnotationsId = annotation.id
            pointAnnotationManager?.annotations.append(annotation)
            self.annotations.append(annotation)
        }
    }
    
    private func activeAnnotationExists(in pointAnnotationManager: PointAnnotationManager) -> Bool {
        pointAnnotationManager.annotations.contains(where: { value in
            value.id == viewModel?.activeAnnotationsId
        } )
    }
    
    private func renewedAnnotations(in pointAnnotationManager: PointAnnotationManager, with annotation: PointAnnotation) -> [PointAnnotation] {
        pointAnnotationManager.annotations.map({ value in
            if value.id == viewModel?.activeAnnotationsId {
                return annotation
            }
            return value
        })
    }
    
    func drawRoute() {
        if annotations.count < 2 {
            return
        }
        var waypoints: [Waypoint] = []
            for annotation in self.annotations {
                let coordinate = annotation.point.coordinates
                waypoints.append(Waypoint(coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)))
            }
        let routeOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .walking)
        Directions.shared.calculate(routeOptions) {[weak self] session, result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self?.mapView.showcase(response.routes ?? [])
            }
        }
    }
    
    func removeRoutes() {
        // Check if the route layer and source exist on the map view
        self.mapView.removeRoutes()
        self.mapView.removeWaypoints()
    }
    
    func deleteAllAnnotations() {
        annotations.removeAll()
        pointAnnotationManager?.annotations.removeAll()
        viewModel?.activeAnnotationsId = ""
    }
    
    @objc public func longPress(_ sender: UILongPressGestureRecognizer) {
        if allowsDynamicPointAnnotations {
            switch sender.state {
            case .began:
                longPressBegan(at: sender.location(in: mapView.mapView))
            default:
                break
            }
        }
    }
}
