//
//  UILabel.swift
//  WildWander
//
//  Created by nuca on 17.07.24.
//

import UIKit

extension UILabel {
    static func textfieldTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18)
        label.textColor = .wildWanderGreen
        label.textAlignment = .left
        
        return label
    }
}
