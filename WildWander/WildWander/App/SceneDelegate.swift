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
        let tabBarController = TabBar()
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
    }

}

