//
//  ExplorePageViewController.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit
import MapboxMaps
import CoreLocation

class ExplorePageViewController: UIViewController {
    private lazy var mapView: WildWanderMapView = {
        let mapView = WildWanderMapView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - 100
        ), allowsDynamicPointAnnotations: false)
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var trailsView: TrailsView = {
        let trailsViewViewModel = TrailsViewViewModel()
        viewModel.trailsDidChange = {[weak self] trails in
            trailsViewViewModel.changeTrails(to: trails)
            self?.mapView.updateStaticAnnotations(with: trails)
        }
        
        mapView.mapDidChangeFrameTo = { [weak self] visibleBounds in
            let upperLongitude = visibleBounds.northwest.longitude
            let upperLatitude = visibleBounds.northwest.latitude
            let lowerLongitude = visibleBounds.southeast.longitude
            let lowerLatitude = visibleBounds.southeast.latitude
            self?.didChangeMapBounds?(upperLongitude, upperLatitude, lowerLongitude, lowerLatitude)
        }
        return TrailsView(viewModel: trailsViewViewModel)
    }()
    
    private lazy var viewModel: ExplorePageViewModel = {
        let mapViewVisibleBounds = mapView.visibleBounds
        let bounds = Bounds(
            upperLongitude: mapViewVisibleBounds.northwest.longitude,
            upperLatitude: mapViewVisibleBounds.northwest.latitude,
            lowerLongitude: mapViewVisibleBounds.southeast.longitude,
            lowerLatitude: mapViewVisibleBounds.southeast.latitude
        )
        return ExplorePageViewModel(viewController: self, currentBounds: bounds)
    }()
    
    var didChangeMapBounds: ((Double, Double, Double, Double) -> Void)?
    
    var sheetNavigationController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        view.backgroundColor = .white
        
        sheetNavigationController = UINavigationController(rootViewController: trailsView)
        
        sheetNavigationController?.modalPresentationStyle = .pageSheet
        
        sheetNavigationController?.isModalInPresentation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentTrailsView()
    }
    
    private func presentTrailsView() {
        if let sheet = sheetNavigationController?.sheetPresentationController {
            let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
            let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
                return 100
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.detents = [smallDetent, .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = smallDetentId
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            self.present(nav, animated: true)
        }
    }
    
}

extension ExplorePageViewController: WildWanderMapViewDelegate {
    func mapStyleButtonTapped(currentMapStyle: MapboxMaps.StyleURI) {
         if let presentedViewController = presentedViewController {
             // If a view controller is already presented, dismiss it before presenting a new one
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
             self?.presentTrailsView()
         }
         
         DispatchQueue.main.async { [weak self] in
             self?.present(mapStyleViewController, animated: true)
         }
     }
}
