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
    private lazy var mapView: WildWanderMapView = {
        let mapView = WildWanderMapView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - 80
        ), allowsDynamicPointAnnotations: true)
        mapView.delegate = self
        
        return mapView
    }()
    private var sheetNavigationController: UINavigationController?
    
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
        
        sheetNavigationController = UINavigationController(rootViewController: makeCustomTrailViewController)
        
        sheetNavigationController?.modalPresentationStyle = .custom
        
        sheetNavigationController?.transitioningDelegate = self
        
        sheetNavigationController?.isModalInPresentation = true
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentMakeCustomTrailView()
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
    
    //MARK: - Methods
    private func presentMakeCustomTrailView() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            tabBarController?.present(nav, animated: true)
        }
    }
    
    func addTrail(_ trail: Trail) {
        trailToDraw = trail
        makeCustomTrailViewController.onTrailAdded()
    }
}

//MARK: - WildWanderMapViewDelegate
extension NavigatePageViewController: WildWanderMapViewDelegate {
    func mapStyleButtonTapped(currentMapStyle: MapboxMaps.StyleURI) {
         if let presentedViewController = presentedViewController {
             
             presentedViewController.dismiss(animated: true) { [weak self] in
                 self?.presentMapStyleViewController(currentMapStyle: currentMapStyle)
             }
         } else {
             presentMapStyleViewController(currentMapStyle: currentMapStyle)
         }
     }
     
     private func presentMapStyleViewController(currentMapStyle: MapboxMaps.StyleURI) {
         let mapStyleViewController = MapStylePageViewController(mapStyle: mapView.mapStyle) { [weak self] changedMapStyle in
             self?.mapView.mapStyle = changedMapStyle
         } sheetDidDisappear: { [weak self] in
             self?.presentMakeCustomTrailView()
         }
         
         DispatchQueue.main.async { [weak self] in
             self?.present(mapStyleViewController, animated: true)
         }
     }
}
