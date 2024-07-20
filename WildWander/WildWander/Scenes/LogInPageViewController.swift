//
//  LogInPageViewController.swift
//  WildWander
//
//  Created by nuca on 17.07.24.
//

import UIKit

class LogInPageViewController: UIViewController {
    //MARK: - Properties
    private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.text = "Log in or sign up to access your profile"
        label.textColor = .wildWanderGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailStackView: UIStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Email", placeholder: "ex: user@gmail.com")
        stackView.setTextFieldDelegate(with: self)
        return stackView
    }()
    
    private lazy var passwordStackView: UIStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Password", placeholder: "ex: Password123")
        stackView.setupSecureEntryOnTextfield()
        return stackView
    }()
    
    private var enterButton: UIButton = {
        let button = UIButton.wildWanderGreenButton(titled: "Enter")
        button.addAction(UIAction { _ in
            
        }, for: .touchUpInside)
        
        return button
    }()
    
    private var dividerView: UIView = {
        let divider = UIView()
        divider.backgroundColor = .lightGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton.wildWanderGrayButton(titled: "Sign up")
        button.addAction(UIAction { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigationController?.pushViewController(InformationEntryViewController(), animated: true)
            }
        }, for: .touchUpInside)
        
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor.wildWanderGreen.cgColor
        
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
            emailStackView,
            passwordStackView,
            enterButton,
            dividerView,
            signUpButton
        ])
        
        [logoImageView,
         explanationLabel,
         emailStackView,
         passwordStackView,
         signUpButton
        ].forEach { view in
            constrainEdgesToMainStackView(view: view, constant: 0)
        }
        
        constrainEdgesToMainStackView(view: dividerView, constant: 40)
        constrainEdgesToMainStackView(view: enterButton, constant: 120)
    }
    
    //MARK: - Constraints
    private func addConstrains() {
        constrainMainStackView()
        constrainDividerView()
        constrainEnterButton()
        constrainLogoImageView()
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func constrainEdgesToMainStackView(view: UIView, constant: CGFloat) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: constant),
            view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -constant),
        ])
    }
    
    private func constrainDividerView() {
        NSLayoutConstraint.activate([
            dividerView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 40),
            dividerView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -40),
        ])
    }
    
    private func constrainEnterButton() {
        NSLayoutConstraint.activate([
            enterButton.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 120),
            enterButton.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -120),
        ])
    }

    private func constrainLogoImageView() {
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
        ])
    }
}

//MARK: - UITextFieldDelegate
extension LogInPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
