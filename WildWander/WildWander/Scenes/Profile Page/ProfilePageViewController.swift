//
//  ProfilePageViewController.swift
//  WildWander
//
//  Created by nuca on 19.07.24.
//

import UIKit
import SwiftUI

class ProfilePageViewController: UIViewController {
    private lazy var sheetNavigationController: UINavigationController = {
        let logInPageViewController = LogInPageViewController(explanationLabelText: "Sign in to access your profile")
        
        logInPageViewController.didLogIn = { [weak self] in
            self?.viewModel.updateLogInStatus()
            self?.viewModel.getUserInformation()
            self?.showOrHideProfile(shouldUpdate: true)
        }
        let sheetNavigationController = UINavigationController(rootViewController: logInPageViewController)
        
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    private lazy var viewModel: ProfilePageViewModel = {
        let viewModel = ProfilePageViewModel()
        
        viewModel.didLogOut = { [weak self] in
            self?.showOrHideProfile(shouldUpdate: false)
            self?.showLogInView()
        }
        
        return viewModel
    }()
    
    private lazy var profileView: UIView = UIHostingController(rootView: ProfilePageView(viewModel: viewModel)).view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileView.topAnchor.constraint(equalTo: view.topAnchor),
            profileView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    
        if viewModel.userLoggedIn {
            viewModel.loadUserDetailsFromLocal()
            viewModel.getUserInformation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLogInView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateLogInStatus()
        
        showOrHideProfile(shouldUpdate: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
        }
    }
    
    //MARK: - Methods
    private func showOrHideProfile(shouldUpdate: Bool) {
        if viewModel.userLoggedIn {
            if shouldUpdate {
                viewModel.getUserInformation()
            }
            profileView.isHidden = false
        } else {
            profileView.isHidden = true
        }
    }
    
    private func showLogInView() {
        if viewModel.userLoggedIn {
        } else {
            present(sheetNavigationController, animated: true)
        }
    }
}

extension ProfilePageViewController: UIViewControllerTransitioningDelegate {
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
