//
//  NavigatePageViewController.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit
import MapboxMaps
import CoreLocation

//example of using WildWanderMapView and MakeCustomTrailViewController
class NavigatePageViewController: UIViewController {
    private lazy var mapView: WildWanderMapView = {
        let mapView = WildWanderMapView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - 300
        ), allowsDynamicPointAnnotations: false)
        mapView.delegate = self
        
        return mapView
    }()
    var sheetNavigationController: UINavigationController?
    
    private lazy var makeCustomTrailViewController = MakeCustomTrailViewController { [weak self] index in
        return self?.mapView.changeActiveAnnotationIndex(to: index) ?? false
    } didDeleteCheckpoint: { [weak self] index in
        self?.mapView.deleteAnnotationOf(index: index) ?? 0
    } didTapOnFinishButton: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = false
        self?.mapView.drawRoute()
    } didTapOnCancelButton: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = false
        self?.mapView.deleteAllAnnotations()
        self?.mapView.removeRoutes()
    } willAddCustomTrail: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = true
    } didTapStartNavigation: { [weak self] in
        self?.mapView.allowsDynamicPointAnnotations = true
    }

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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
    
    private func presentMakeCustomTrailView() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            self.present(nav, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        mapView.didLoad()
    }
}

extension NavigatePageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let tabSheetPresentationController = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        tabSheetPresentationController.detents = [
            .smallThanMedium(),
        ]
        tabSheetPresentationController.largestUndimmedDetentIdentifier = .smallThanMedium
        tabSheetPresentationController.prefersGrabberVisible = true
        tabSheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        tabSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        tabSheetPresentationController.selectedDetentIdentifier = .medium

        return tabSheetPresentationController
    }
}

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
