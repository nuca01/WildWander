//
//  TextfieldAndTitleStackView.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit

class TextfieldAndTitleStackView: UIStackView {
    //MARK: - Properties
    private var textField: UITextField
    private var titleLabel: UILabel
    
    var textFieldText: String? {
        textField.text
    }
    
    //MARK: - Initializers
    init(title: String, placeholder: String) {
        self.textField = UITextField.wildWanderTextField(placeholder: placeholder)
        self.titleLabel = UILabel.textfieldTitleLabel(text: title)
        
        super.init(frame: .zero)
        
        setUpStackView()
        
        addArranged(subviews: [titleLabel, textField])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func setUpStackView() {
        axis = .vertical
        distribution = .equalSpacing
        alignment = .fill
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setTextFieldDelegate(with textFieldDelegate: UITextFieldDelegate) {
        textField.delegate = textFieldDelegate
    }
    
    func setupSecureEntryOnTextfield() {
        textField.toggleVisibility()
        textField.setButtonForSecureEntry()
    }
}
