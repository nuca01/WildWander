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
    private var allowsDynamicPointAnnotations: Bool = false
    
    private var pointAnnotationManager: PointAnnotationManager?
    
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
        
        if allowsDynamicPointAnnotations {
            pointAnnotationManager = mapView.mapView.annotations.makePointAnnotationManager()
            pointAnnotationManager?.delegate = self
            setupExample()
        }
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
    
    private func setupExample() {
        try? mapView.mapView.mapboxMap.style.addImage(UIImage(named: "redMarker")!, id: "redMarker")
        try? mapView.mapView.mapboxMap.style.addImage(UIImage(named: "blueMarker")!, id: "blueMarker")
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func changeActiveAnnotationIndex(to index: Int) {
        let arrayCount = viewModel?.annotationIds.count ?? 0
    
        if index > arrayCount {
            return
        }
        
        changeOldActiveAnnotationMarker()
        
        if index == arrayCount {
            viewModel?.activeAnnotationsId = ""
        } else {
            let futureActiveAnnotation = pointAnnotationManager?.annotations.first(where: { annotation in
                annotation.id == viewModel?.annotationIds[index]
            })
            
            let futureActiveAnnotationIndex = pointAnnotationManager?.annotations.firstIndex(where: { annotation in
                annotation.id == viewModel?.annotationIds[index]
            })
            
            pointAnnotationManager?.annotations[futureActiveAnnotationIndex!].iconImage = "redMarker"
            viewModel?.activeAnnotationsId = futureActiveAnnotation!.id
        }
    }
    
    private func changeOldActiveAnnotationMarker() {
        if let activeAnnotationsId = viewModel?.activeAnnotationsId
        {
            let activeAnnotationIndex = pointAnnotationManager?.annotations.firstIndex(where: { annotation in
                annotation.id == activeAnnotationsId
            }) ?? 0
            pointAnnotationManager?.annotations[activeAnnotationIndex].iconImage = "blueMarker"
        }
    }
    
    func deleteAnnotationOf(index: Int) -> Int? {
        let annotationsCount = viewModel?.activeAnnotationsId.count ?? 0
        if index >= annotationsCount {
            return nil
        }
        
        if viewModel?.annotationIds[index] == viewModel?.activeAnnotationsId && annotationsCount > 1 {
            changeToFutureActiveAnnotation()
        }
        
        pointAnnotationManager?.annotations.removeAll(where: { annotation in
            annotation.id == viewModel?.annotationIds[index]
        })
        
        viewModel?.annotationIds.remove(at: index)
        return viewModel?.annotationIds.firstIndex(of: viewModel?.activeAnnotationsId ?? "")
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
        
        let camera = CameraOptions(center: coordinate)
        mapView.mapView.camera.ease(to: camera, duration: 0.5)
    }
    
    private func appendAnnotationsArray(with annotation: PointAnnotation) {
        if let activeAnnotationId = viewModel?.activeAnnotationsId, let pointAnnotationManager, activeAnnotationExists(in: pointAnnotationManager)
        {
            pointAnnotationManager.annotations = renewedAnnotations(in: pointAnnotationManager, with: annotation)
            let currentActiveAnnotationIndexInVM = viewModel?.annotationIds.firstIndex(of: activeAnnotationId)
            
            viewModel?.annotationIds[currentActiveAnnotationIndexInVM!] = annotation.id
            viewModel?.activeAnnotationsId = annotation.id
        } else {
            viewModel?.annotationIds.append(annotation.id)
            viewModel?.activeAnnotationsId = annotation.id
            pointAnnotationManager?.annotations.append(annotation)
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
    
    @objc public func longPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            longPressBegan(at: sender.location(in: mapView.mapView))
        default:
            break
        }
    }
}
