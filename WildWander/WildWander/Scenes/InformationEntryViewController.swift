//
//  InformationEntryViewController.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import UIKit
import SwiftUI

class InformationEntryViewController: UIViewController {
    //MARK: - Properties
    private var viewModel: InformationEntryViewModel
    private var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22)
        label.text = "Last step! You're almost there!"
        label.textColor = .wildWanderGreen
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var firstNameStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "First Name", placeholder: "ex: William")
        stackView.setTextFieldDelegate(with: self)
        return stackView
    }()
    
    private lazy var lastNameStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Last name", placeholder: "ex: Anderson")
        stackView.setTextFieldDelegate(with: self)
        return stackView
    }()
    
    private lazy var dateOfBirthStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Date of birth", placeholder: "DD/MM/YYYY")
        stackView.setTextFieldDelegate(with: self)
        stackView.setTextFieldsInputView(to: datePicker)
        stackView.setTextFieldsInputAccessoryView(to: toolbar(doneAction: #selector(donePressedForDate)))
        return stackView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1900
        components.month = 1
        components.day = 1
        let minDate = calendar.date(from: components)
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = Date()
        return datePicker
    }()
    
    private lazy var genderStackView: TextfieldAndTitleStackView = {
        let stackView = TextfieldAndTitleStackView(title: "Gender", placeholder: "Select Gender")
        stackView.setTextFieldDelegate(with: self)
        stackView.setTextFieldsInputView(to: genderPicker)
        stackView.setTextFieldsInputAccessoryView(to: toolbar(doneAction: #selector(donePressedForGender)))
        return stackView
    }()
    
    private lazy var genderPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
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
            viewModel.register(
                password: passwordStackView.textFieldText ?? "",
                firstName: firstNameStackView.textFieldText ?? "",
                lastName: lastNameStackView.textFieldText ?? "",
                gender: genderStackView.textFieldText ?? ""
            )
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
    
    private var loaderView: UIView? = {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        loaderView?.backgroundColor = .clear
        return loaderView
    }()
    
    lazy var resignOnTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    var didLogIn: (() -> Void)?
    
    //MARK: - Initializers
    init(email: String) {
        self.viewModel = InformationEntryViewModel(email: email)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.didTryToRegister = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let errorMessage {
                    self.errorLabel.text = errorMessage
                    self.errorLabel.isHidden = false
                } else {
                    self.errorLabel.isHidden = true
                    self.didLogIn?()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        addConstraints()
        if let loaderView {
            view.addSubview(loaderView)
            constrainLoaderView()
        }
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
            firstNameStackView,
            lastNameStackView,
            dateOfBirthStackView,
            genderStackView,
            passwordStackView,
            errorLabel,
            enterButton,
        ])
    }
    
    //MARK: - Constraints
    private func addConstraints() {
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
         firstNameStackView,
         lastNameStackView,
         dateOfBirthStackView,
         genderStackView,
         passwordStackView,
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
    
    private func toolbar(doneAction: Selector?) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: doneAction)
        toolbar.setItems([doneButton], animated: true)
        return toolbar
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
    
    @objc private func donePressedForDate() {
        let formattedDate = viewModel.formatted(date: datePicker.date)
        dateOfBirthStackView.textFieldText = formattedDate
        view.endEditing(true)
    }
    
    @objc private func donePressedForGender() {
        genderStackView.textFieldText = viewModel.genderFor(index: genderPicker.selectedRow(inComponent: 0))
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension InformationEntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UIPickerViewDataSource
extension InformationEntryViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderStackView.textFieldText = viewModel.genderFor(index: row)
    }
}

//MARK: - UIPickerViewDelegate
extension InformationEntryViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.genderCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.genderFor(index: row)
    }
}
