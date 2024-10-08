//
//  EmailEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit
import SwiftUI

class EmailEntryViewController: UIViewController {
    //MARK: - Properties
    private lazy var viewModel: EmailEntryViewModel = {
        let viewModel = EmailEntryViewModel()
        
        viewModel.didSendAnEmail = { errorMessage in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let errorMessage {
                    errorLabel.text = errorMessage
                    errorLabel.isHidden = false
                } else {
                    errorLabel.isHidden = true
                    let codeEntryViewController = (CodeEntryViewController(email: emailStackView.textFieldText ?? ""))
                    codeEntryViewController.didLogIn =  didLogIn
                                                                
                    navigationController?.pushViewController(codeEntryViewController, animated: true)
                }
                loaderView?.isHidden = true
            }
        }
        return viewModel
    }()
    
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
    
    private var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .red
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton.wildWanderGreenButton(titled: "Enter")
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            loaderView?.isHidden = false
            viewModel.sendCodeTo(emailStackView.textFieldText ?? "")
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
    
    private var loaderView: UIView? = {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        loaderView?.backgroundColor = .clear
        return loaderView
    }()
    
    lazy var resignOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    var didLogIn: (() -> Void)?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        addConstrains()
        if let loaderView {
            view.addSubview(loaderView)
            loaderView.isHidden = true
            constrainLoaderView()
        }
        view.addGestureRecognizer(resignOnTapGesture)
    }
    
    //MARK: - Methods
    private func addSubviews() {
        view.addSubview(mainStackView)
        
        addMainStackViewSubViews()
    }
    
    private func addMainStackViewSubViews() {
        mainStackView.addArranged(subviews: [
            logoImageView,
            explanationLabel,
            emailStackView,
            UIView(),
            errorLabel,
            enterButton,
        ])
    }
    
    //MARK: - Constraints
    private func addConstrains() {
        constrainMainStackView()
        constrainLogoImageView()
        constrainMainStackViewSubviews()
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func constrainMainStackViewSubviews() {
        [logoImageView,
         explanationLabel,
         emailStackView,
         errorLabel,
         enterButton
        ].forEach { view in
            constrainEdgesToMainStackView(view: view, constant: 0)
        }
    }
    
    private func constrainEdgesToMainStackView(view: UIView, constant: CGFloat) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: constant),
            view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -constant),
        ])
    }

    private func constrainLoaderView() {
        if let loaderView {
            NSLayoutConstraint.activate([
                loaderView.heightAnchor.constraint(equalToConstant: 20),
                loaderView.widthAnchor.constraint(equalToConstant: 20),
                loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
    }
    
    private func constrainLogoImageView() {
        NSLayoutConstraint.activate([
            logoImageView.heightAnchor.constraint(equalToConstant: 160),
        ])
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension EmailEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
