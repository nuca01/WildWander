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
        return self?.mapView.viewModel?.customTrailPolyline
    } didTapAddTrail: { [weak self] in
        DispatchQueue.main.async { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }
    }
    
    private var trailToDraw: Trail?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        view.backgroundColor = .white
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
