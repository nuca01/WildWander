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
        let trailsView = TrailsView(viewModel: trailsViewViewModel)
        
        trailsView.didTapOnCell = { [weak self] trail in
            guard let self else { return }
            let navigatePage = self.tabBarController?.viewControllers?[1] as! NavigatePageViewController
            navigatePage.addTrail(trail)
            self.tabBarController?.selectedIndex = 1
            
        }
        
        return trailsView
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
    
    private var searchBar: SearchBarView = SearchBarView()
    
    var didChangeMapBounds: ((Double, Double, Double, Double) -> Void)?
    
    var sheetNavigationController: UINavigationController?
    
    private lazy var searchPage: SearchPageViewController = SearchPageViewController { [weak self] in
        self?.presentTrailsView()
    } didSelectLocation: { [weak self] location in
        guard let self else { return }
        if let location {
            searchBar.text = location.displayName
            
            if let latitude = location.latitude, let longitude = location.longitude {
                mapView.changeCameraOptions(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        } else {
            searchBar.text = nil
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        
        view.backgroundColor = .white
        
        configureSheetNavigationController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentTrailsView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.changeCameraOptions(zoom: 5)
    }
    
    private func configureSheetNavigationController() {
        sheetNavigationController = UINavigationController(rootViewController: trailsView)
        
        sheetNavigationController?.modalPresentationStyle = .custom
        
        sheetNavigationController?.transitioningDelegate = self
        
        sheetNavigationController?.isModalInPresentation = true
    }
    
    private func presentTrailsView() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            tabBarController?.present(nav, animated: true)
        }
    }
}

extension ExplorePageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let tabSheetPresentationController = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        tabSheetPresentationController.detents = [
            .small(),
            .medium(),
            .myLarge(),
        ]
        tabSheetPresentationController.largestUndimmedDetentIdentifier = .myLarge
        tabSheetPresentationController.prefersGrabberVisible = true
        tabSheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        tabSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        tabSheetPresentationController.selectedDetentIdentifier = .medium

        return tabSheetPresentationController
    }
}

extension ExplorePageViewController: WildWanderMapViewDelegate {
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
             self?.presentTrailsView()
         }
         
         DispatchQueue.main.async { [weak self] in
             self?.present(mapStyleViewController, animated: true)
         }
     }
}

extension ExplorePageViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.presentSearchPage()
            }
        } else {
            presentSearchPage()
        }
        return false
    }
    
    private func presentSearchPage() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            present(searchPage, animated: true)
        }
    }
}
