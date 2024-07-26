//
//  LogInPageViewController.swift
//  WildWander
//
//  Created by nuca on 17.07.24.
//

import UIKit

class LogInPageViewController: UIViewController {
    //MARK: - Properties
    private lazy var viewModel: LogInPageViewModel = {
        let viewModel = LogInPageViewModel()
        viewModel.didTryToLogIn = { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage {
                    self?.errorLabel.text = errorMessage
                    self?.errorLabel.isHidden = false
                } else {
                    self?.errorLabel.isHidden = true
                    self?.dismiss(animated: true)
                    self?.didLogIn?()
                }
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
        label.text = "Log in or sign up to access your profile"
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
    
    private lazy var passwordStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Password", placeholder: "ex: Password123")
        stackView.setTextFieldDelegate(with: self)
        stackView.setupSecureEntryOnTextfield()
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
            
            viewModel.logIn(
                email: emailStackView.textFieldText ?? "",
                password: passwordStackView.textFieldText ?? ""
            )
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
        button.addAction(UIAction { _ in
            DispatchQueue.main.async { [weak self]  in
                guard let self else { return }
                let emailEntryViewController = EmailEntryViewController()
                emailEntryViewController.didLogIn = didLogIn
                navigationController?.pushViewController(emailEntryViewController, animated: true)
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
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var didLogIn: (() -> Void)?
    
    //MARK: - Initializers
    init(explanationLabelText: String) {
        explanationLabel.text = explanationLabelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var resignOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        addConstrains()
        view.addGestureRecognizer(resignOnTapGesture)
    }
    
    //MARK: - Methods
    private func addSubviews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(mainStackView)
        
        addMainStackViewSubViews()
    }
    
    private func addMainStackViewSubViews() {
        mainStackView.addArranged(subviews: [
            logoImageView,
            explanationLabel,
            emailStackView,
            passwordStackView,
            errorLabel,
            enterButton,
            dividerView,
            signUpButton
        ])
    }
    
    //MARK: - Constraints
    private func addConstrains() {
        constrainScrollView()
        constrainMainStackView()
        constrainDividerView()
        constrainEnterButton()
        constrainLogoImageView()
        constrainMainStackViewSubviews()
        constrainEdgesToMainStackView(view: dividerView, constant: 40)
        constrainEdgesToMainStackView(view: enterButton, constant: 120)
    }
    
    private func constrainScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func constrainMainStackViewSubviews() {
        [logoImageView,
         explanationLabel,
         emailStackView,
         passwordStackView,
         errorLabel,
         signUpButton
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension LogInPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
