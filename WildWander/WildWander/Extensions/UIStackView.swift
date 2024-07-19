//
//  UIStackView.swift
//  WildWander
//
//  Created by nuca on 14.07.24.
//

import UIKit

extension UIStackView {
    static func generateHorizontalButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    static func generateTextfieldAndTitleStackView(title: String, placeholder: String, textFieldDelegate: UITextFieldDelegate, allowsSecureEntry: Bool = false) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel.textfieldTitleLabel(text: title)
        let textField = UITextField.wildWanderTextField(placeholder: placeholder)
        textField.delegate = textFieldDelegate
        if allowsSecureEntry {
            textField.toggleVisibility()
            textField.setButtonForSecureEntry()
        }
        
        stackView.addArranged(subviews: [titleLabel, textField])
        return stackView
    }
    
    func addArranged(subviews: [UIView]) {
        subviews.forEach { view in
            addArrangedSubview(view)
        }
    }
}
