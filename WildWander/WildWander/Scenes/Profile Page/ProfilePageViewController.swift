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
        
        return sheetNavigationController
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        present(sheetNavigationController, animated: true)
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
