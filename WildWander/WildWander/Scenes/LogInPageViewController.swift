//
//  LogInPageViewController.swift
//  WildWander
//
//  Created by nuca on 17.07.24.
//

import UIKit

class LogInPageViewController: UIViewController {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .wildWanderGreen
        label.textAlignment = .left
        
        return label
    }()
    
    private var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ex: user@gmail.com"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.wildWanderGreen.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var titleAndTextFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArranged(subviews: [titleLabel, emailTextField])
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wildWanderExtraLightGray
        view.addSubview(titleAndTextFieldStackView)
        NSLayoutConstraint.activate([
            emailTextField.heightAnchor.constraint(equalToConstant: 55),
            titleAndTextFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleAndTextFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleAndTextFieldStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleAndTextFieldStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}

