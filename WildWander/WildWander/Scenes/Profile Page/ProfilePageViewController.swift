//
//  ProfilePageViewController.swift
//  WildWander
//
//  Created by nuca on 19.07.24.
//

import UIKit

class ProfilePageViewController: UIViewController {
    private lazy var sheetNavigationController: UINavigationController = {
        let sheetNavigationController = UINavigationController(rootViewController: LogInPageViewController())
        
        sheetNavigationController.modalPresentationStyle = .custom
        sheetNavigationController.transitioningDelegate = self
        sheetNavigationController.isModalInPresentation = true
        sheetNavigationController.isModalInPresentation = true
        
        return sheetNavigationController
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        present(sheetNavigationController, animated: true)
    }
}

extension ProfilePageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let tabSheetPresentationController = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        tabSheetPresentationController.detents = [
            .large()
        ]
        tabSheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        tabSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        tabSheetPresentationController.selectedDetentIdentifier = .large

        return tabSheetPresentationController
    }
}
