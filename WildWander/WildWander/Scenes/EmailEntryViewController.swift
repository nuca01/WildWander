//
//  EmailEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit

class EmailEntryViewController: UIViewController {
    //MARK: - Properties
    private lazy var viewModel: EmailEntryViewModel = {
        let viewModel = EmailEntryViewModel()
        
        viewModel.didSendAnEmail = { errorMessage in
            DispatchQueue.main.async {
                if let errorMessage {
                    self.errorLabel.text = errorMessage
                    self.errorLabel.isHidden = false
                    
                } else {
                    self.errorLabel.isHidden = true
                    
                    self.navigationController?.pushViewController(CodeEntryViewController(email: self.emailStackView.textFieldText ?? ""), animated: true)
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
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        view.addSubview(scrollView)
        
        scrollView.addSubview(mainStackView)
        
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
        constrainScrollView()
        constrainMainStackView()
        constrainLogoImageView()
        constrainMainStackViewSubviews()
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
