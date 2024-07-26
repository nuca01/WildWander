//
//  TabBar.swift
//  WildWander
//
//  Created by nuca on 26.07.24.
//

import UIKit

class TabBar: UITabBarController {
    //MARK: - Properties
    private var explorePageViewController = {
        let viewController = ExplorePageViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "location.magnifyingglass"),
            selectedImage: UIImage(systemName: "location.magnifyingglass")
        )
        
        return viewController
    }()
    private var navigatePageViewController = {
        let viewController = NavigatePageViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "Navigate",
            image: UIImage(systemName: "location"),
            selectedImage: UIImage(systemName: "location.fill")
        )
        
        return viewController
    }()
    
    private var savedPageViewController = {
        let viewController = UINavigationController(rootViewController: SavedPageViewController())
        viewController.tabBarItem = UITabBarItem(
            title: "Saved",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        return viewController
    }()
    
    private var profilePageViewController = {
        let viewController = ProfilePageViewController()
        viewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        return viewController
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    

    //MARK: - Set Up
    private func setupTabBar() {
        viewControllers = [
            explorePageViewController,
            navigatePageViewController,
            savedPageViewController,
            profilePageViewController
        ]
        tabBar.tintColor = .wildWanderGreen
    }
}
