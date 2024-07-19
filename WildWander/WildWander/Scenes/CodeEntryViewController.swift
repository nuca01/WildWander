//
//  CodeEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit

class CodeEntryViewController: UIViewController {
    private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.text = "Check your email for the code"
        label.textColor = .wildWanderGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var codeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for number in 0...4 {
            stackView.addArrangedSubview(generateCodeNumberTextfield(with: number))
        }
        
        return stackView
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton.wildWanderGreenButton(titled: "Enter")
        button.addAction(UIAction { [weak self] _ in
            
        }, for: .touchUpInside)
        
        return button
    }()
    
    private var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        addConstrains()
    }
    
    //MARK: - Methods
    private func addSubviews() {
        view.addSubview(mainStackView)
        
        mainStackView.addArranged(subviews: [
            logoImageView,
            explanationLabel,
            codeStackView,
            enterButton,
        ])
        
        [logoImageView,
         explanationLabel,
         enterButton
        ].forEach { view in
            constrainEdgesToMainStackView(view: view, constant: 0)
        }
    }
    
    //MARK: - Constraints
    private func addConstrains() {
        constrainMainStackView()
        constrainLogoImageView()
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func constrainCodeStackView() {
        NSLayoutConstraint.activate([
        ])
    }
    
    private func constrainEdgesToMainStackView(view: UIView, constant: CGFloat) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: constant),
            view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -constant),
        ])
    }

    private func constrainLogoImageView() {
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
        ])
    }

    private func generateCodeNumberTextfield(with tag: NSInteger) -> UITextField {
        let textfield = UITextField()
        textfield.layer.borderColor = UIColor.wildWanderGreen.cgColor
        textfield.layer.borderWidth = 2
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textfield.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textfield.font = .systemFont(ofSize: 30)
        textfield.leftViewMode = .always
        textfield.rightViewMode = .always
        textfield.layer.cornerRadius = 10
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.masksToBounds = true
        textfield.textAlignment = .center
        textfield.delegate = self
        textfield.tag = tag
        
        NSLayoutConstraint.activate([
            textfield.heightAnchor.constraint(equalToConstant: 50),
            textfield.widthAnchor.constraint(equalToConstant: 50),
        ])
        return textfield
    }
}

extension CodeEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let x = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
            return true
        } else {
            return false
        }
    }
}
