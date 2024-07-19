//
//  SceneDelegate.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let tabBarController = UITabBarController()
        
        let firstViewController = ExplorePageViewController()
        let secondViewController = NavigatePageViewController()
        let thirdViewController = ProfilePageViewController()
        
        firstViewController.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "location.magnifyingglass"),
            selectedImage: UIImage(systemName: "location.magnifyingglass")
        )
        
        secondViewController.tabBarItem = UITabBarItem(
            title: "Navigate",
            image: UIImage(systemName: "location"),
            selectedImage: UIImage(systemName: "location.fill")
        )
        
        thirdViewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        tabBarController.viewControllers = [firstViewController, secondViewController, thirdViewController]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

