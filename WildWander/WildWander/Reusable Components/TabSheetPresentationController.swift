//
//  TabSheetPresentationController.swift
//  WildWander
//
//  Created by nuca on 14.07.24.
//

import UIKit

class TabSheetPresentationController : UISheetPresentationController {
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        if let tabBarController = presentingViewController as? UITabBarController, let containerView {
            containerView.clipsToBounds = true
            var frame = containerView.frame
            frame.size.height -= tabBarController.tabBar.frame.height
            containerView.frame = frame
        }
    }
}
