//
//  SavedPageViewController.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import UIKit
import SwiftUI

class SavedPageViewController: UIViewController {
    //MARK: - Properties
    private lazy var viewModel: SavedPageViewModel = {
        let viewModel = SavedPageViewModel()
        return viewModel
    }()
    
    private lazy var listsTableViewModel = ListsTableViewModel()
    
    private lazy var listsTableView: ListsTableView = {
        let listsTableView = ListsTableView(viewModel: listsTableViewModel)
        
        listsTableViewModel.listDidChange = { [weak self] in
            DispatchQueue.main.async {
                listsTableView.reloadData()
                self?.loaderView?.isHidden = true
            }
        }
        
        viewModel.onTrailCreated = { self.listsTableViewModel.getSavedLists() }
        
        listsTableView.didTapOnCreateNewList = configureDidTapOnCreateNewList()
        
        listsTableView.didTapOnList = { [weak self] (id, name, description) in
            guard let self else { return }
            viewModel.getTrails(listId: id)
            var trailsViewModel = TrailsViewViewModel()
            
            viewModel.trailsDidChange = { [weak self] trails in
                trailsViewModel.changeTrails(to: trails)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let trailsView = TrailsView(viewModel: trailsViewModel, name: name, description: description)
                navigationController?.pushViewController(trailsView, animated: true)
            }
        }
        
        return listsTableView
    }()
    
    private lazy var logInPageViewController = {
        let logInPageViewController = LogInPageViewController(explanationLabelText: "Sign in to save trails")
        
        logInPageViewController.didLogIn = { [weak self] in
            guard let self else { return }
            if showListsTableView() {
                listsTableViewModel.getSavedLists()
            }
        }
        
        return logInPageViewController
    }()
    
    private lazy var sheetNavigationController: UINavigationController = {
        let sheetNavigationController = UINavigationController(rootViewController: logInPageViewController)
        
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    private var loaderView: UIView? = {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        loaderView?.backgroundColor = .clear
        return loaderView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listsTableView)
        
        if let loaderView {
            view.addSubview(loaderView)
            constrainLoaderView()
        }
        
        view.backgroundColor = .white
        constrainListsTableView()
        DispatchQueue.main.async { [weak self] in
            self?.listsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !viewModel.userLoggedIn {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                logInPageViewController.setToDefault()
                sheetNavigationController.popToRootViewController(animated: false)
                present(sheetNavigationController, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showListsTableView() {
            listsTableViewModel.getSavedLists()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }

    //MARK: - Methods
    private func constrainLoaderView() {
        if let loaderView {
            NSLayoutConstraint.activate([
                loaderView.heightAnchor.constraint(equalToConstant: 20),
                loaderView.widthAnchor.constraint(equalToConstant: 20),
                loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
    }
    
    private func constrainListsTableView() {
        NSLayoutConstraint.activate([
            listsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            listsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            listsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func configureDidTapOnCreateNewList() -> (() -> Void) {
        { [weak self] in
            let createAListView = CreateAListView() { [weak self] (name, description) in
                self?.viewModel.createList(createListModel: CreateList(name: name, description: description))
                
                self?.dismissCreateAListView()
            }
            
            self?.present(createAListView)
        }
    }
    
    private func dismissCreateAListView() {
        if let presentedViewController {
            DispatchQueue.main.async {
                presentedViewController.dismiss(animated: true)
            }
        }
    }
    
    private func present(_ createAListView: CreateAListView) {
        let controller = UIHostingController(rootView: createAListView)
        DispatchQueue.main.async { [weak self] in
            self?.present(controller, animated: true)
        }
    }
    
    private func showListsTableView() -> Bool {
        if viewModel.userLoggedIn {
            loaderView?.isHidden = false
            listsTableView.isHidden = false
            return true
        } else {
            listsTableView.isHidden = true
            return false
        }
    }
}

extension SavedPageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let tabSheetPresentationController = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        tabSheetPresentationController.detents = [
            .large()
        ]
        tabSheetPresentationController.largestUndimmedDetentIdentifier = .large
        tabSheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        tabSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        tabSheetPresentationController.selectedDetentIdentifier = .large

        return tabSheetPresentationController
    }
}
