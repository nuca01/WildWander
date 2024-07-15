//
//  ButtonsStackView.swift
//  WildWander
//
//  Created by nuca on 15.07.24.
//

import UIKit

class ButtonsStackView: UIStackView {
    private var leftButton: UIButton
    private var rightButton: UIButton
    
    //MARK: - Initializers
    init(
        leftTitle: String,
        rightTitle: String,
        leftAction: UIAction,
        rightAction: UIAction
    ) {
        self.leftButton = UIButton.wildWanderGrayButton(titled: leftTitle)
        self.rightButton =  UIButton.wildWanderGreenButton(titled: rightTitle)
        super.init(frame: CGRect.zero)
        addActions(leftAction, rightAction)
        addSubviews()
        setUpModifiers()
        constrainButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func addSubviews() {
        addArranged(subviews: [leftButton, rightButton])
    }
    
    private func addActions(_ leftAction: UIAction, _ rightAction: UIAction) {
        leftButton.addAction(leftAction, for: .touchUpInside)
        rightButton.addAction(rightAction, for: .touchUpInside)
    }
    
    private func setUpModifiers() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 20
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func constrainButtons() {
        arrangedSubviews.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }
}
