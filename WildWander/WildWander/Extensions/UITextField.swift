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
        textField.autocorrectionType = .no
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 55),
        ])
        return textField
    }
    
    //MARK: - Secure Entry
    
    func setButtonForSecureEntry() {
        let secureEntryButton = UIButton()
        
        let closedEyeImage = UIImage(named: "closedEye")
        let openEyeImage = UIImage(named: "openEye")
        
        secureEntryButton.setImage(closedEyeImage, for: .normal)
        secureEntryButton.tintColor = .wildWanderGreen
        secureEntryButton.imageView?.contentMode = .scaleAspectFit
        secureEntryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secureEntryButton.heightAnchor.constraint(equalToConstant: 20),
            secureEntryButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        secureEntryButton.addAction(UIAction { [weak self] _ in
            if secureEntryButton.imageView?.image === closedEyeImage {
                secureEntryButton.setImage(openEyeImage, for: .normal)
            } else {
                secureEntryButton.setImage(closedEyeImage, for: .normal)
            }
            
            self?.toggleVisibility()
        }, for: .touchUpInside)
        
        rightView = secureEntryButton
        rightViewMode = .always
    }
    
    func toggleVisibility() {
        isSecureTextEntry.toggle()
        
        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            
            text = existingText
        }
        
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}
