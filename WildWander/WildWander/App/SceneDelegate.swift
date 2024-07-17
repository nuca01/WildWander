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
        let secondViewController = LogInPageViewController()
        
        firstViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        secondViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
        
        tabBarController.viewControllers = [firstViewController, secondViewController]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

