//
//  NavigatePageViewController + UIViewControllerTransitioningDelegate.swift
//  WildWander
//
//  Created by nuca on 14.07.24.
//

import UIKit

extension NavigatePageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let tabSheetPresentationController = TabSheetPresentationController(presentedViewController: presented, presenting: source)
        tabSheetPresentationController.detents = [
            .small(),
            .smallThanMedium(),
            .interactiveMedium()
        ]
        tabSheetPresentationController.largestUndimmedDetentIdentifier = .interactiveMedium
        tabSheetPresentationController.prefersGrabberVisible = true
        tabSheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        tabSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        tabSheetPresentationController.selectedDetentIdentifier = .smallThanMedium

        return tabSheetPresentationController
    }
}
