//
//  UIButton.swift
//  WildWander
//
//  Created by nuca on 14.07.24.
//

import UIKit

extension UIButton {
    static func wildWanderGreenButton(titled title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .wildWanderGreen
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    static func wildWanderGrayButton(titled title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .wildWanderExtraLightGray
        button.setTitle(title, for: .normal)
        button.setTitleColor(.wildWanderGreen, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
}
