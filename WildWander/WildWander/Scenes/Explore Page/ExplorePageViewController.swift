//
//  ExplorePageViewController.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit
import MapboxMaps
import CoreLocation
import SwiftUI

class ExplorePageViewController: UIViewController {
    //MARK: - Properties
    internal lazy var mapView: WildWanderMapView = {
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
            self?.didChangeMapBounds(to: visibleBounds)
        }
        let trailsView = TrailsView(viewModel: trailsViewViewModel)
        
        viewModel.errorDidHappen = { [weak self] (title, description) in
            trailsView.showErrorMessage(title: title, description: description)
        }
        
        trailsView.didTapOnCell = { [weak self] trail in
            guard let self else { return }
            let navigatePage = self.tabBarController?.viewControllers?[1] as! TrailAddable
            navigatePage.addTrail(trail)
            self.tabBarController?.selectedIndex = 1
        }
        
        configureDidTapSave(for: trailsView)
        
        return trailsView
    }()
    
    private lazy var viewModel: ExplorePageViewModel = ExplorePageViewModel(currentBounds: mapBounds)
    
    private lazy var searchBar: SearchBarView = {
        let searchBar = SearchBarView()
        searchBar.delegate = self
        return searchBar
    }()

    var sheetNavigationController: UINavigationController?
    
    private lazy var searchPage: SearchPageViewController = SearchPageViewController { [weak self] in
        self?.presentConstantView()
    } didSelectLocation: { [weak self] location in
        guard let self else { return }
        
        if let presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
        
        if let location {
            searchBar.text = location.displayName
            
            if let latitude = location.latitude, let longitude = location.longitude {
                mapView.changeCameraOptions(center: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0), zoom: 12, duration: 0.0)
            }
        } else {
            searchBar.text = nil
        }
    }
    
    private var mapBounds: Bounds {
        mapView.visibleBounds
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.backgroundColor = .white
        
        configureSheetNavigationController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentConstantView()
        didChangeMapBounds(to: mapBounds)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        didChangeMapBounds(to: mapBounds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateLogInStatus()
    }
    
    //MARK: - Methods
    private func configureSheetNavigationController() {
        sheetNavigationController = UINavigationController(rootViewController: trailsView)
        
        sheetNavigationController?.modalPresentationStyle = .custom
        
        sheetNavigationController?.transitioningDelegate = self
        
        sheetNavigationController?.isModalInPresentation = true
    }
    
    private func didChangeMapBounds(to bounds: Bounds) {
        trailsView.trailsWillChange()
        viewModel.getTrailsWith(bounds: bounds)
    }
    
    private func configureDidTapSave(for trailsView: TrailsView) {
        trailsView.didTapSave = { [weak self] willSave in
            guard let self else { return }
            let listsTableView = configureListsTableView(for: trailsView)
            
            configureDidTapOnCreateNewList(for: listsTableView, with: willSave)
            
            configureDidTapOnListWithId(
                for: listsTableView,
                with: willSave
            )
            
            present(listsTableView)
        }
    }
    
    private func configureListsTableView(for trailsView: TrailsView) -> ListsTableView {
        let listsTableViewModel = ListsTableViewModel()
        listsTableViewModel.getSavedLists()
        
        return ListsTableView(viewModel: listsTableViewModel)
    }
    
    private func configureDidTapOnCreateNewList(
        for listsTableView: ListsTableView,
        with willSave: @escaping (String?, String?, Int?) -> Void
    ) {
        listsTableView.didTapOnCreateNewList = { [weak self] in
            if let presentedViewController = self?.presentedViewController {
                let createAListView = CreateAListView() { (name, description) in
                    willSave(name, description, nil)
                    DispatchQueue.main.async {
                        self?.presentedViewController?.dismiss(animated: true)
                        self?.presentConstantView()
                    }
                }
                
                let controller = UIHostingController(rootView: createAListView)
                DispatchQueue.main.async {
                    presentedViewController.dismiss(animated: true)
                    self?.present(controller, animated: true)
                }
            }
        }
    }
    
    private func configureDidTapOnListWithId(
        for listsTableView: ListsTableView,
        with willSave: @escaping (String?, String?, Int?) -> Void
    ) {
        listsTableView.didTapOnList = { [weak self] (id, _, _) in
            guard let self else { return }
            if let presentedViewController {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    presentedViewController.dismiss(animated: true)
                    willSave(nil, nil, id)
                    self.presentConstantView()
                    self.viewModel.getTrailsWith(bounds: self.mapBounds)
                }
            }
        }
    }
    
    private func present(_ listsTableView: ListsTableView) {
        let controller = UITableViewController()
        controller.tableView = listsTableView
        
        if let presentedViewController {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                presentedViewController.dismiss(animated: true)
                present(controller, animated: true)
            }
        }
    }
}

//MARK: - ExplorePageViewController
extension ExplorePageViewController: WildWanderMapViewDelegate {
    internal func presentConstantView() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let nav = self.sheetNavigationController  else { return }
            tabBarController?.present(nav, animated: true)
        }
    }
}

//MARK: - ExplorePageViewController
extension ExplorePageViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let presentedViewController {
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
