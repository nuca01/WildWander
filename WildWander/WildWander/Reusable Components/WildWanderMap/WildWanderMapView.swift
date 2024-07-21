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

final class WildWanderMapView: UIView {
    //MARK: - Properties
    weak var delegate: WildWanderMapViewDelegate?
    var viewModel: WildWanderMapViewModel?
    var willAccessUsersLocation: (() -> Void)?
    var didTapOnAnnotation: ((_: Int?) -> Void)?
    var mapDidChangeFrameTo: ((Bounds) -> Void)?
    
    let locationDisabledAlert = WildWanderAlertView(
        title: "share your location",
        message: "in order to access your location you need to grant app the location permission",
        firstButtonTitle: "Go To Settings",
        dismissButtonTitle: "Maybe Later"
    )
    
    
    private lazy var pointAnnotationManager: PointAnnotationManager = {
        let pointAnnotationManager = mapView.mapView.annotations.makePointAnnotationManager()
        
        return pointAnnotationManager
    }()
    
    private lazy var polyLineAnnotationManagers: [PolylineAnnotationManager] = {
        let borderPolylineAnnotationManager = mapView.mapView.annotations.makePolylineAnnotationManager(layerPosition: .above("road-primary"))
        
        let routePolylineAnnotationManager = mapView.mapView.annotations.makePolylineAnnotationManager(layerPosition: .above(borderPolylineAnnotationManager.layerId))
        
        return [borderPolylineAnnotationManager, routePolylineAnnotationManager]
    }()
    
    var allowsDynamicPointAnnotations: Bool = false
    private var annotations: [PointAnnotation] = []
    private var trails: [String: Int] = [:]
    
    var visibleBounds: Bounds {
        let mapViewFrame = mapView.mapView.frame

        let topLeftScreenCoordinate = CGPoint(x: mapViewFrame.minX, y: mapViewFrame.minY)
        let bottomRightScreenCoordinate = CGPoint(x: mapViewFrame.maxX, y: mapViewFrame.maxY)

        let topLeftCoordinate = mapView.mapView.mapboxMap.coordinate(for: topLeftScreenCoordinate)
        let bottomRightCoordinate = mapView.mapView.mapboxMap.coordinate(for: bottomRightScreenCoordinate)
        
        return Bounds(
            upperLongitude: topLeftCoordinate.longitude,
            upperLatitude: topLeftCoordinate.latitude,
            lowerLongitude: bottomRightCoordinate.longitude,
            lowerLatitude: bottomRightCoordinate.latitude
        )
    }
    
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
        mapView.gestures.delegate = self
        
        let navigationMapView = NavigationMapView(frame: bounds, mapView: mapView)
        
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        navigationMapView.userLocationStyle = .puck2D(configuration: configuration)
        return navigationMapView
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
        button.addAction(userLocationAction, for: .touchUpInside)
        
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
    
    private lazy var userLocationAction: UIAction = UIAction { [weak self] _ in
        self?.centerUserLocation()
    }
    
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
        setupAnnotationsIcons()
        pointAnnotationManager.delegate = self
        
        if allowsDynamicPointAnnotations {
            setupDynamicAnnotationsGesture()
            self.allowsDynamicPointAnnotations = false
        }
    }
    
    //MARK: - SetUpViews
    private func setUpViews() {
        addSubview(mapView)
        addSubview(buttonsStackView)
        constrainButtons()
        constrainButtonsStackView()
        constrainCompass()
    }
    
    private func constrainCompass() {
        mapView.mapView.ornaments.compassView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.mapView.ornaments.compassView.topAnchor.constraint(equalToSystemSpacingBelow: buttonsStackView.topAnchor, multiplier: 1),
            mapView.mapView.ornaments.compassView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10)
        ])
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
    func changeCameraOptions(
        center: CLLocationCoordinate2D? = nil,
        padding: UIEdgeInsets? = nil,
        anchor: CGPoint? = nil,
        zoom: CGFloat? = nil,
        bearing: CLLocationDirection? = nil,
        pitch: CGFloat? = nil,
        duration: TimeInterval = 1
    ) {
        mapView.mapView.camera.ease(to: CameraOptions(
            center: center,
            padding: padding,
            anchor: anchor,
            zoom: zoom,
            bearing: bearing,
            pitch: pitch
        ), duration: duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            self.mapDidChangeFrameTo?(visibleBounds)
        }
    }
    
    private func centerMapOnUserLocation() {
        willAccessUsersLocation?()
        guard let location = mapView.mapView.location.latestLocation else { return }
        changeCameraOptions(center: location.coordinate, zoom: 11)
    }
    
    private func showLocationDisabledAlert() {
        locationDisabledAlert.onFirstButtonTapped = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        locationDisabledAlert.show(in: self)
    }
    
    func updateStaticAnnotations(with trails: [Trail]) {
        deleteAllAnnotations()
        var newAnnotations: [PointAnnotation] = []
        
        trails.forEach { trail in
            let startCoordinate = CLLocationCoordinate2D(latitude: trail.startLatitude ?? 0.0, longitude: trail.startLongitude ?? 0.0)
            var annotation = PointAnnotation(point: Point(startCoordinate))
            annotation.iconImage = "redMarker"
            
            if annotation.userInfo == nil {
                annotation.userInfo = [:]
            }
            
            annotation.userInfo?["routeGeometry"] = trail.routeGeometry
            annotation.userInfo?["id"] = trail.id
            
            newAnnotations.append(annotation)
        }
        
        self.pointAnnotationManager.annotations = newAnnotations
        self.annotations = newAnnotations
    }
    
    func drawStaticAnnotationRouteWith(routeGeometry: String? = nil, routeCoordinates: [CLLocationCoordinate2D]? = nil) {
        removeRoutes()
        
        var coordinates: [CLLocationCoordinate2D] = routeCoordinates ?? []
        if let routeGeometry {
            coordinates = routeGeometry.decodePolyline() ?? []
        }
        var polyLineAnnotationLineString = PolylineAnnotation(lineCoordinates: coordinates).lineString
        
        
        drawRoute(with: polyLineAnnotationLineString)
        
        DispatchQueue.main.async {
            self.changeCameraOptions(center: coordinates.first, zoom: 12, duration: 0.0)
        }
    }
    
    private func drawRoute(with lineString: LineString) {
        drawOneLineWith(lineString: lineString, color: .routeOutline, width: 9, polyLineAnnotationManagerIndexInContainer: 0)
        drawOneLineWith(lineString: lineString, color: .route, width: 7, polyLineAnnotationManagerIndexInContainer: 1)
    }
    
    private func drawOneLineWith(
        lineString: LineString,
        color: UIColor,
        width: Double,
        polyLineAnnotationManagerIndexInContainer: Int
    ) {
        var annotation = PolylineAnnotation(lineString: lineString)
        annotation.lineColor = StyleColor(color)
        annotation.lineWidth = width
        polyLineAnnotationManagers[polyLineAnnotationManagerIndexInContainer].annotations = [annotation]
    }
    
    private func centerUserLocation() {
        if self.viewModel!.userLocationIsEnabled {
            self.centerMapOnUserLocation()
        } else {
            self.showLocationDisabledAlert()
        }
    }
}

//MARK: - Annotations
extension WildWanderMapView: AnnotationInteractionDelegate {
    func annotationManager(_ manager: any MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [any MapboxMaps.Annotation]) {
        if !allowsDynamicPointAnnotations {
            if let id = annotations.last?.userInfo?["id"] as? Int {
                didTapOnAnnotation?(id)
            }
        }
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
            pointAnnotationManager.annotations = pointAnnotationManager.annotations.map({ annotation in
                var newAnnotation = annotation
                if annotation.id == activeAnnotationsId  {
                    newAnnotation.iconImage = "blueMarker"
                }
                return newAnnotation
            })
        }
    }
    
    private func changeMarkerOfFutureActiveAnnotation(of index: Int) {
        pointAnnotationManager.annotations = pointAnnotationManager.annotations.map({ annotation in
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
        pointAnnotationManager.annotations.removeAll(where: { annotation in
            annotation.id == id
        })
        
        self.annotations.removeAll (where: { annotation in
            annotation.id == id
        })
    }
    
    private func changeToFutureActiveAnnotation() {
        var futureActiveAnnotationFound = false
        pointAnnotationManager.annotations = pointAnnotationManager.annotations.map({ annotation in
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
        deletePolyLines()
        
        var annotation = getAnnotationFromPressed(location)
        
        annotation.iconImage = "redMarker"
        appendAnnotationsArray(with: annotation)
    }
    
    private func getAnnotationFromPressed(_ location: CGPoint) -> PointAnnotation {
        let coordinate = mapView.mapView.mapboxMap.coordinate(for: location)
        
        return PointAnnotation(point: Point(coordinate))
    }
    
    private func appendAnnotationsArray(with annotation: PointAnnotation) {
        if let activeAnnotationId = viewModel?.activeAnnotationsId, activeAnnotationExistsInPointAnnotationManager()
        {
            pointAnnotationManager.annotations = renewedAnnotations(in: pointAnnotationManager, with: annotation)
            changeActiveAnnotationInAnnotationsContainer(with: annotation)
            
            viewModel?.activeAnnotationsId = annotation.id
        } else {
            viewModel?.activeAnnotationsId = annotation.id
            pointAnnotationManager.annotations.append(annotation)
            self.annotations.append(annotation)
        }
    }
    
    private func changeActiveAnnotationInAnnotationsContainer(with annotation: PointAnnotation) {
        let currentActiveAnnotationIndexInContainer = self.annotations.firstIndex { value in
            value.id == viewModel?.activeAnnotationsId
        }
        
        self.annotations[currentActiveAnnotationIndexInContainer!] = annotation
    }
    
    private func activeAnnotationExistsInPointAnnotationManager() -> Bool {
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
    
    func drawCustomRoute() {
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
            case .success(let response):                self?.drawStaticAnnotationRouteWith(routeCoordinates: response.routes?.first?.shape?.coordinates)
            }
        }
    }
    
    func removeRoutes() {
        self.mapView.removeRoutes()
        self.mapView.removeWaypoints()
    }
    
    func deleteAllAnnotations() {
        annotations.removeAll()
        pointAnnotationManager.annotations.removeAll()
        viewModel?.activeAnnotationsId = ""
        deletePolyLines()
    }
    
    func startNavigation() -> Bool {
        if viewModel!.userLocationIsEnabled {
            tiltAndFollowBearing()
            userLocationButton.removeAction(identifiedBy: userLocationAction.identifier, for: .touchUpInside)
            userLocationAction = UIAction { [weak self] _ in
                self?.tiltAndFollowBearing()
            }
            userLocationButton.addAction(userLocationAction, for: .touchUpInside)
            
            return true
        } else {
            showLocationDisabledAlert()
            return false
        }
    }
    
    func finishNavigation() {
        mapView.mapView.viewport.idle()
        changeCameraOptions(pitch: 0)
        userLocationButton.removeAction(identifiedBy: userLocationAction.identifier, for: .touchUpInside)
        userLocationAction = UIAction { [weak self] _ in
            self?.centerUserLocation()
        }
        userLocationButton.addAction(userLocationAction, for: .touchUpInside)
    }
    
    
    private func tiltAndFollowBearing() {
        let followPuckViewportStateOptions = FollowPuckViewportStateOptions(
            bearing: .course,
            pitch: 45
        )
        let followPuckViewportState = mapView.mapView.viewport.makeFollowPuckViewportState(options: followPuckViewportStateOptions)

        DispatchQueue.main.async { [weak self] in
            self?.mapView.mapView.viewport.transition(to: followPuckViewportState)
        }
    }
    
    private func deletePolyLines() {
        polyLineAnnotationManagers[0].annotations = []
        polyLineAnnotationManagers[1].annotations = []
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

extension WildWanderMapView: GestureManagerDelegate {
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {

        
        if !willAnimate {
            mapDidChangeFrameTo?(visibleBounds)
        }
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
        mapDidChangeFrameTo?(visibleBounds)
    }
}
