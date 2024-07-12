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
        let mapView = WildWanderMapView(frame: view.bounds, allowsDynamicPointAnnotations: true)
        mapView.delegate = self
        
        return mapView
    }()
    var sheetNavigationController: UINavigationController?
    
    private lazy var controller = MakeCustomTrailViewController { [weak self] index in
        return self?.mapView.changeActiveAnnotationIndex(to: index) ?? false
    } didDeleteCheckpoint: { [weak self] index in
        self?.mapView.deleteAnnotationOf(index: index) ?? 0
    } didTapOnFinishButton: { [weak self] in
        self?.mapView.drawRoute()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        sheetNavigationController = UINavigationController(rootViewController: controller)
        
        sheetNavigationController?.modalPresentationStyle = .pageSheet
        
        sheetNavigationController?.isModalInPresentation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentMakeCustomTrailView()
    }
    
    private func presentMakeCustomTrailView() {
        if let sheet = sheetNavigationController?.sheetPresentationController {
            let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
            let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
                return 300
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.detents = [smallDetent]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = smallDetentId
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            self.present(nav, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        mapView.didLoad()
    }
}

extension NavigatePageViewController: WildWanderMapViewDelegate {
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
             self?.presentMakeCustomTrailView()
         }

         if let sheet = mapStyleViewController.sheetPresentationController {
             let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
             let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
                 return 180
             }
             
             sheet.detents = [smallDetent]
             sheet.prefersGrabberVisible = true
         }
         
         present(mapStyleViewController, animated: true) { [weak self] in
             self?.presentMakeCustomTrailView()
         }
     }
}
