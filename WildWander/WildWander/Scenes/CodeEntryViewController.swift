//
//  CodeEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit
import SwiftUI

class CodeEntryViewController: UIViewController {
    private var viewModel: CodeEntryViewModel
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
            self?.viewModel.validate()
            self?.loaderView?.isHidden = false
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
    
    //MARK: - Initializers
    init(email: String) {
        viewModel = CodeEntryViewModel(email: email)
        super.init(nibName: nil, bundle: nil)
        viewModel.didCheckCode = {(didPassChecking, error) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if didPassChecking {
                    errorLabel.isHidden = true
                    let informationEntryViewController = InformationEntryViewController(email: email)
                    informationEntryViewController.didLogIn = didLogIn
                    navigationController?.pushViewController(informationEntryViewController, animated: true)
                } else {
                    if let error {
                        errorLabel.text = error
                    } else {
                        errorLabel.text = "wrong code entered"
                    }
                    errorLabel.isHidden = false
                }
                loaderView?.isHidden = true
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            codeStackView,
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
    
    private func constrainMainStackViewSubviews() {
        [logoImageView,
         explanationLabel,
         errorLabel,
         enterButton
        ].forEach { view in
            constrainEdgesToMainStackView(view: view, constant: 0)
        }
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
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
    
    private func changeToNextResponder(for textField: UITextField) -> UITextField? {
        if let nextField = view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            return nextField
        } else {
            textField.resignFirstResponder()
        }
        return nil
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CodeEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = changeToNextResponder(for: textField)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 { return false }
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 1 {
            if let nextField = changeToNextResponder(for: textField) {
                nextField.text = string
                viewModel.ChangeCodeNumber(for: textField.tag + 1, with: string)
            }
            return false
        }
        
        if string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil || string.isEmpty {
            viewModel.ChangeCodeNumber(for: textField.tag, with: string)
            return true
        } else {
            return false
        }
    }
}
