//
//  EmailEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit

class EmailEntryViewController: UIViewController {
    //MARK: - Properties
    private var viewModel: EmailEntryViewModel = EmailEntryViewModel()
    private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.text = "Let's start with your Email"
        label.textColor = .wildWanderGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Email", placeholder: "ex: user@gmail.com")
        stackView.setTextFieldDelegate(with: self)
        return stackView
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton.wildWanderGreenButton(titled: "Enter")
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
                viewModel.sendCodeTo("example@example.com") { message in
                if let message = message {
                    print("Error: \(message)")
                } else {
                    print("Code sent successfully")
                }
            }
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
            emailStackView,
            enterButton,
        ])
        
        [logoImageView,
         explanationLabel,
         emailStackView,
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
}

//MARK: - UITextFieldDelegate
extension EmailEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
