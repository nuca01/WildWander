//
//  ViewController.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit
import MapboxMaps
import CoreLocation

//example of using WildWanderMapView
class ViewController: UIViewController {
    private lazy var mapView: WildWanderMapView = {
        let mapView = WildWanderMapView(frame: view.bounds)
        mapView.delegate = self
        
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
    }
    
    override func viewDidLayoutSubviews() {
        mapView.didLoad()
    }
}

extension ViewController: WildWanderMapViewDelegate {
    func mapStyleButtonTapped(currentMapStyle: MapboxMaps.StyleURI) {
        let mapStyleViewController = MapStylePageViewController(mapStyle: mapView.mapStyle) { [weak self] changedMapStyle in
            self?.mapView.mapStyle = changedMapStyle
        }
        
        if let sheet = mapStyleViewController.sheetPresentationController {
            let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
            let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
                return 180
            }
            
            sheet.detents = [smallDetent]
        }
        
        present(mapStyleViewController, animated: true)
    }
}
