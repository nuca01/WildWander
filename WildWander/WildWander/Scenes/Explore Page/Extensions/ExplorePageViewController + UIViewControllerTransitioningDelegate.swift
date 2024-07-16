//
//  ExplorePageViewController + UIViewControllerTransitioningDelegate.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import UIKit

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
