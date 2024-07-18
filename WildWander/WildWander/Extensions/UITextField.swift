//
//  UITextField.swift
//  WildWander
//
//  Created by nuca on 17.07.24.
//

import UIKit

extension UITextField {
    static func wildWanderTextField (placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.wildWanderGreen.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 55),
        ])
        return textField
    }
}
