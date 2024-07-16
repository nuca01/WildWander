//
//  WildWanderMapViewDelegate.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import Foundation
import MapboxMaps

protocol WildWanderMapViewDelegate: UIViewController {
    func mapStyleButtonTapped(currentMapStyle: StyleURI)
    func presentConstantView()
    var mapView: WildWanderMapView {get set}
    
}

extension WildWanderMapViewDelegate {
    func mapStyleButtonTapped(currentMapStyle: MapboxMaps.StyleURI) {
         if let presentedViewController = presentedViewController {
             presentedViewController.dismiss(animated: true) { [weak self] in
                 self?.presentMapStyleViewController(currentMapStyle: currentMapStyle)
             }
         } else {
             presentMapStyleViewController(currentMapStyle: currentMapStyle)
         }
     }
     
    func presentMapStyleViewController(currentMapStyle: MapboxMaps.StyleURI) {
         let mapStyleViewController = MapStylePageViewController(mapStyle: mapView.mapStyle) { [weak self] changedMapStyle in
             self?.mapView.mapStyle = changedMapStyle
         } sheetDidDisappear: { [weak self] in
             self?.presentConstantView()
         }
         
         DispatchQueue.main.async { [weak self] in
             self?.present(mapStyleViewController, animated: true)
         }
     }
}
