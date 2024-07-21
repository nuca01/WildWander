//
//  WildWanderAlertView.swift
//  WildWander
//
//  Created by nuca on 11.07.24.
//

import UIKit

final class WildWanderAlertView: UIView {
    //MARK: - Properties
    private let containerView: UIView = {
        let uiView = UIView()
        uiView.backgroundColor = .white
        uiView.layer.cornerRadius = 10
        uiView.translatesAutoresizingMaskIntoConstraints = false
        
        return uiView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var firstButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(firstButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var dismissButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var onFirstButtonTapped: (() -> Void)?
    
    //MARK: - Initializers
    init(
        title: String,
        message: String,
        firstButtonTitle: String? = nil,
        dismissButtonTitle: String
    ) {
        super.init(frame: .zero)
        setupViews()
        
        configure(
            title: title,
            message: message,
            firstButtonTitle: firstButtonTitle ?? "",
            dismissButtonTitle: dismissButtonTitle
        )
        
        if firstButtonTitle == nil {
            firstButton.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    //MARK: - Methods
    private func setupViews() {
        setAlphaComponentForAnimation()
        
        setBackgroundColor()
        
        addSubViews()
        
        setupConstraints()
    }
    
    private func configure(
        title: String,
        message: String,
        firstButtonTitle: String,
        dismissButtonTitle: String
    ) {
        titleLabel.text = title
        messageLabel.text = message
        firstButton.setTitle(firstButtonTitle, for: .normal)
        dismissButton.setTitle(dismissButtonTitle, for: .normal)
    }
    
    //MARK: - Helper Methods
    private func setAlphaComponentForAnimation() {
        self.alpha = 0.0
    }
    
    private func setBackgroundColor() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    private func addSubViews() {
        self.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        
        containerView.addSubview(messageLabel)
        
        containerView.addSubview(firstButton)
        
        containerView.addSubview(dismissButton)
    }
    
    private func setupConstraints() {
        constrainContainerView()
        
        constrainSubviewsToContainerView()
        
        constrainTitleLabel()
        
        constrainMessageLabel()
        
        constrainFirstButton()
        
        constrainDismissButton()
    }
    
    private func constrainContainerView() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    private func constrainSubviewsToContainerView() {
        [
            titleLabel,
            messageLabel,
            firstButton,
            dismissButton
        ].forEach { view in
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            ])
        }
    }
    
    private func constrainTitleLabel() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
        ])
    }
    
    private func constrainMessageLabel() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
        ])
    }
    
    private func constrainFirstButton() {
        NSLayoutConstraint.activate([
            firstButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            firstButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func constrainDismissButton() {
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: firstButton.bottomAnchor, constant: 10),
            dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            dismissButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func show(in view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 1.0
        })
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc private func firstButtonTapped() {
        onFirstButtonTapped?()
        dismiss()
    }
    
    @objc private func dismissButtonTapped() {
        dismiss()
    }
}
