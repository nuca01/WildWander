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
        let sheetNavigationController = UINavigationController(rootViewController: LogInPageViewController(explanationLabelText: "Sign in to access your profile"))
        
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    private let viewModel: ProfilePageViewModel = ProfilePageViewModel()
    
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
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.userLoggedIn {
        } else {
            present(sheetNavigationController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateLogInStatus()
        
        if viewModel.userLoggedIn {
            viewModel.getUserInformation()
            profileView.isHidden = false
        } else {
            profileView.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true)
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
