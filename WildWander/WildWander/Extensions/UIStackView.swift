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
    
    func addArranged(subviews: [UIView]) {
        subviews.forEach { view in
            addArrangedSubview(view)
        }
    }
}
