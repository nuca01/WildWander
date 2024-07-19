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
        
        firstViewController.tabBarItem = UITabBarItem(
            title: "Explore Page",
            image: UIImage(named: "explorePageInactive"),
            selectedImage: UIImage(named: "explorePageActive")?.withTintColor(.wildWanderGreen)
        )
        
        secondViewController.tabBarItem = UITabBarItem(
            title: "Navigate Page",
            image: UIImage(named: "navigatePage"),
            selectedImage: UIImage(named: "navigatePage")?.withTintColor(.wildWanderGreen)
        )
        
        tabBarController.viewControllers = [firstViewController, secondViewController]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

