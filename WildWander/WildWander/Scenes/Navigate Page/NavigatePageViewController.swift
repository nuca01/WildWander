//
//  NavigatePageViewController.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit
import MapboxMaps
import CoreLocation

class NavigatePageViewController: UIViewController {
    //MARK: - Properties
    internal lazy var mapView: WildWanderMapView = {
        let mapView = WildWanderMapView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - 80
        ), allowsDynamicPointAnnotations: true)
        mapView.delegate = self
        
        return mapView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(
            pointSize: 55, weight: .medium, scale: .default)
        let image = UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        button.addAction(UIAction { [weak self] _ in
            self?.handleSearchButtonTapped()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .wildWanderGreen
        button.layer.cornerRadius = 27.5
        return button
    }()
    
    private var searchPage: SearchPageViewController?
    
    private lazy var sheetNavigationController: UINavigationController = {
        sheetNavigationController = UINavigationController(rootViewController: makeCustomTrailViewController)
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    private lazy var makeCustomTrailViewController = TrailShownViewController { [weak self] index in
        return self?.mapView.changeActiveAnnotationIndex(to: index) ?? false
    } didDeleteCheckpoint: { [weak self] index in
        self?.mapView.deleteAnnotationOf(index: index) ?? 0
    } didTapOnFinishButton: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = false
        self?.mapView.drawCustomRoute()
    } didTapOnCancelButton: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = false
        self?.mapView.deleteAllAnnotations()
        self?.mapView.removeRoutes()
    } willAddCustomTrail: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = true
    } didTapStartNavigation: { [weak self] in
        guard let self else { return false }
        return self.mapView.startNavigation()
    } didTapFinishNavigation: { [weak self] in
        self?.mapView.finishNavigation()
    } didFinish: { [weak self] (customTrailCreated, saveInformation) in
        if customTrailCreated {
            self?.showPublishTrailAlert(with: saveInformation)
        } else {
            saveInformation(nil)
        }
    } didTapAddTrail: { [weak self] in
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }
    } willPublishTrail: { [weak self] in
        self?.mapView.viewModel?.customTrail ?? TrailDetails()
    }
    
    private var trailToDraw: Trail?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        
        view.addSubview(searchButton)
        
        view.bringSubviewToFront(searchButton)
        
        constrainSearchButton()
        
        initializeSearchPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentConstantView()
        if let trailToDraw {
            mapView.drawStaticAnnotationRouteWith(routeGeometry: trailToDraw.routeGeometry)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
        trailToDraw = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeCustomTrailViewController.viewModel.checkIfTokenChangedToNil()
    }
    
    //MARK: - Methods
    private func constrainSearchButton() {
        NSLayoutConstraint.activate([
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -7),
            searchButton.heightAnchor.constraint(equalToConstant: 55),
            searchButton.widthAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func showPublishTrailAlert(
        with saveInformation: @escaping (_: TrailDetails) -> Void
    ) {
        let dimmedView = dimPresentedView()
        
        let publishTrailAlert = WildWanderAlertView(
            title: "Do you want to publish the trail you just completed?",
            message: "Publishing the trail means it will be available for everyone to see and complete.",
            firstButtonTitle: "Publish the trail",
            dismissButtonTitle: "Not this time"
        )
        
        publishTrailAlert.onFirstButtonTapped = { [weak self] in
            guard let self else { return }
            
            saveInformation(mapView.viewModel?.customTrail ?? TrailDetails())
            dimmedView.removeFromSuperview()
        }
        
        publishTrailAlert.onCancelTapped = { [weak self] in
            guard let self else { return }
            mapView.viewModel?.customTrail?.length = nil
            mapView.viewModel?.customTrail?.time = nil
            
            saveInformation(mapView.viewModel?.customTrail ?? TrailDetails())
            dimmedView.removeFromSuperview()
        }
        
        publishTrailAlert.show(in: view)
    }
    
    private func initializeSearchPage() {
        searchPage = SearchPageViewController { [weak self] in
            self?.presentConstantView()
        } didSelectLocation: { [weak self] location in
            guard let self else { return }
            
            if let presentedViewController {
                presentedViewController.dismiss(animated: true)
            }
            
            if let location {
                if let latitude = location.latitude, let longitude = location.longitude {
                    mapView.changeCameraOptions(center: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0), zoom: 12, duration: 0.0)
                }
            }
        }
    }
    
    private func dimPresentedView() -> UIView {
        let dimmedView = UIView()
        dimmedView.frame = makeCustomTrailViewController.view.bounds
        dimmedView.backgroundColor = .black.withAlphaComponent(0.6)
        makeCustomTrailViewController.view.addSubview(dimmedView)
        sheetNavigationController.sheetPresentationController?.selectedDetentIdentifier = .small
        
        return dimmedView
    }
    
    private func presentSearchPage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let searchPage {
                present(searchPage, animated: true)
            }
        }
    }
    
    private func handleSearchButtonTapped() {
        if let presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.presentSearchPage()
            }
        } else {
            presentSearchPage()
        }
    }
}

//MARK: - WildWanderMapViewDelegate
extension NavigatePageViewController: WildWanderMapViewDelegate {
    func presentConstantView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            tabBarController?.present(sheetNavigationController, animated: true)
        }
    }
}

extension NavigatePageViewController: TrailAddable {
    func addTrail(_ trail: Trail) {
        trailToDraw = trail
        makeCustomTrailViewController.onTrailAdded()
        makeCustomTrailViewController.trailID = trail.id
    }
}
