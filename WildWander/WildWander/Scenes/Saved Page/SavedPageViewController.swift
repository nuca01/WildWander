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
        
        viewModel.onTrailCreated = { self.listsTableViewModel.getSavedLists() }
        
        listsTableView.didTapOnCreateNewList = configureDidTapOnCreateNewList()
        listsTableView.didTapOnList = { [weak self] (id, name, description) in
            var trailsViewModel = TrailsViewViewModel()
            self?.viewModel.trailsDidChange = { trails in
                trailsViewModel.changeTrails(to: trails)
            }
            self?.viewModel.getTrails(listId: id)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let trailsView = TrailsView(viewModel: trailsViewModel, name: name, description: description)
                navigationController?.pushViewController(trailsView, animated: true)
            }
        }
        
        return listsTableView
    }()
    
    private lazy var sheetNavigationController: UINavigationController = {
        let sheetNavigationController = UINavigationController(rootViewController: LogInPageViewController(explanationLabelText: "Sign in to save trails"))
        
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listsTableView)
        view.backgroundColor = .white
        constrainListsTableView()
        DispatchQueue.main.async { [weak self] in
            self?.listsTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isUserLoggedIn {
            listsTableViewModel.getSavedLists()
        } else {
            listsTableView.isHidden = true
            present(sheetNavigationController, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }

    //MARK: - Methods
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
