//
//  ViewController.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit
class ViewController: UIViewController {
    
//    private var mapView = WildWanderMapView()
    private var searchBar = SearchBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(mapView)
//        
//        NSLayoutConstraint.activate([
//            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
//            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            print("did it")
//            self.mapView.cameraOptions.bearing = 60
//        }
    }
}

