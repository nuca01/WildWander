//
//  MakeCustomTrailViewController.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit

class MakeCustomTrailViewController: UIViewController {
    //MARK: - Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    //MARK: - addTrailAndChooseTrailStackView
    private lazy var addTrailAndChooseTrailStackView: UIStackView = {
        generateMainButtonsStackView()
    }()
    
    private lazy var addTrailButton: UIButton = {
        let button = generateRightButton(with: "Add Trail")
        button.addAction(UIAction { [weak self] _ in
            
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var chooseTrailButton: UIButton = {
        let button = generateLeftButton(with: "Choose Trail")
        button.addAction(UIAction { [weak self] _ in
            self?.addTrailAndChooseTrailStackView.removeFromSuperview()
            self?.configureCustomTrailView()
        }, for: .touchUpInside)
        return button
    }()
    
    //MARK: - customTrailStackView
    private lazy var customTrailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addRemoveStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.addCheckPoint()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "minus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.removeCheckPoint()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var checkPointsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var finishButton: UIButton = {
        let button = generateRightButton(with: "Finish")
        button.addAction(UIAction { [weak self] _ in
            guard let self else {return}
            self.customTrailStackView.removeFromSuperview()
            self.configureButtonsView(for: self.customTrailNavigationStackView, and: [self.editTrailButton, self.startTrailButton])
            self.didTapOnFinishButton()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = generateLeftButton(with: "Cancel")
        button.addAction(UIAction { [weak self] _ in
            guard let self else {return}
            self.customTrailStackView.removeFromSuperview()
            self.configureButtonsView(for: self.addTrailAndChooseTrailStackView, and: [self.addTrailButton, self.chooseTrailButton])
            self.didTapOnCancelButton()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelAndFinishStackView: UIStackView = {
        generateMainButtonsStackView()
    }()
    
    //MARK: - customTrailNavigationStackView
    private lazy var customTrailNavigationStackView: UIStackView = {
        generateMainButtonsStackView()
    }()
    
    private lazy var editTrailButton: UIButton = {
        let button = generateRightButton(with: "Edit Trail")
        button.addAction(UIAction { [weak self] _ in
            self?.customTrailNavigationStackView.removeFromSuperview()
            self?.configureCustomTrailView()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var startTrailButton: UIButton = {
        let button = generateLeftButton(with: "Start Trail")
        button.addAction(UIAction { [weak self] _ in
            self?.addTrailAndChooseTrailStackView.removeFromSuperview()
            self?.didTapStartNavigation()
        }, for: .touchUpInside)
        return button
    }()
    
    //MARK: - SearchBar
    private lazy var searchBar: SearchBarView = {
        let searchBar = SearchBarView()
        searchBar.delegate = self
        searchBar.searchBarDelegate = self
        
        return searchBar
    }()
//    private lazy var customTrailStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.alignment = .trailing
//        stackView.distribution = .fill
//        stackView.spacing = 20
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//    
    private var activeButtonIndex: Int? {
        didSet {
            if let activeButtonIndex {
                checkPointsStackView.subviews[activeButtonIndex].layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    
    private var labels: [UILabel] = []
    
    var didTapOnChooseOnTheMap: (_: Int) -> Bool
    
    var didDeleteCheckpoint: (_: Int) -> Int
    
    var didTapOnFinishButton: () -> Void
    
    var didTapOnCancelButton: () -> Void
    
    var willAddCustomTrail: () -> Void
    
    var didTapStartNavigation: () -> Void
    
    //MARK: - Initializers
    init(didTapOnChooseOnTheMap: (
        @escaping (_: Int) -> Bool),
         didDeleteCheckpoint: (@escaping (_: Int) -> Int),
         didTapOnFinishButton: @escaping () -> Void,
         didTapOnCancelButton: @escaping () -> Void,
         willAddCustomTrail: @escaping () -> Void,
         didTapStartNavigation: @escaping () -> Void
    ) {
        self.didTapOnChooseOnTheMap = didTapOnChooseOnTheMap
        self.didDeleteCheckpoint = didDeleteCheckpoint
        self.didTapOnFinishButton = didTapOnFinishButton
        self.didTapOnCancelButton = didTapOnCancelButton
        self.willAddCustomTrail = willAddCustomTrail
        self.didTapStartNavigation = didTapStartNavigation
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        view.backgroundColor = .white
        constrainScrollView()
        configureButtonsView(for: addTrailAndChooseTrailStackView, and: [addTrailButton, chooseTrailButton])
    }
    
    //MARK: - Methods
    private func addSubviews() {
        view.addSubview(scrollView)
    }
    
    private func configureButtonsView(for stackView: UIStackView, and buttons: [UIButton]) {
        scrollView.addSubview(stackView)
        buttons.forEach { view in
            stackView.addArrangedSubview(view)
        }
        constrainToScrollView(stackView)
        constrainMainButtonsOf(stackView)
    }
    
    private func configureCustomTrailView() {
        willAddCustomTrail()
        scrollView.addSubview(customTrailStackView)
        [checkPointsStackView, addRemoveStackView, cancelAndFinishStackView].forEach { view in
            customTrailStackView.addArrangedSubview(view)
        }
        
        [addButton, removeButton].forEach { view in
            addRemoveStackView.addArrangedSubview(view)
        }
        
        [finishButton, cancelButton].forEach { view in
            cancelAndFinishStackView.addArrangedSubview(view)
        }
        
        constrainToScrollView(customTrailStackView)
        constrainCheckPointsStackView()
        constrainAddAndRemoveButtons()
        
        constrainMainButtonsOf(cancelAndFinishStackView)
        
        NSLayoutConstraint.activate([
            cancelAndFinishStackView.leadingAnchor.constraint(equalTo: customTrailStackView.leadingAnchor),
            cancelAndFinishStackView.trailingAnchor.constraint(equalTo: customTrailStackView.trailingAnchor),
        ])
        
        if checkPointsStackView.subviews.count < 2 {
            addCheckPoint()
            addCheckPoint()
        }
    }
    
    private func constrainScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func constrainToScrollView(_ view: UIView) {
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    private func constrainMainButtonsOf(_ stackView: UIStackView) {
        stackView.subviews.forEach { button in
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }
    
    private func constrainCheckPointsStackView() {
        NSLayoutConstraint.activate([
            checkPointsStackView.leadingAnchor.constraint(equalTo: customTrailStackView.leadingAnchor),
            checkPointsStackView.trailingAnchor.constraint(equalTo: customTrailStackView.trailingAnchor),
        ])
    }
    
    private func constrainAddAndRemoveButtons() {
        [addButton, removeButton]
            .forEach { button in
                NSLayoutConstraint.activate([
                    button.heightAnchor.constraint(equalToConstant: 20),
                    button.widthAnchor.constraint(equalToConstant: 20),
                ])
            }
    }
    
    private func addCheckPoint() {
        checkPointsStackView.addArrangedSubview(generateCheckPointButton())
        
        if activeButtonIndex == nil {
            activeButtonIndex = checkPointsStackView.subviews.count - 1
        }
    }
    
    private func removeCheckPoint() {
        if let activeButtonIndex {
            if checkPointsStackView.subviews.count == 2 { return }
            let futureActiveIndex = didDeleteCheckpoint(activeButtonIndex)
            checkPointsStackView.subviews[activeButtonIndex].removeFromSuperview()
            labels.remove(at: activeButtonIndex)
            
            labels.enumerated().forEach { (index, label) in
                labels[index].text = "CheckPoint \(index + 1)"
            }
            self.activeButtonIndex = futureActiveIndex
        }
    }
    
    private func generateCheckPointButton() -> UIButton {
        let greenColor = UIColor(red: 71/255, green: 92/255, blue: 55/255, alpha: 1)
        let checkPointNumber = self.checkPointsStackView.subviews.count
        
        let button = generateButton(with: greenColor)
        
        addLabel(color: greenColor, checkPointNumber: checkPointNumber, superView: button)
        
        addImage(color: greenColor, checkPointNumber: checkPointNumber, superView: button)
        
        return button
    }
    
    private func generateButton(with color: UIColor) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 3
        button.layer.borderColor = color.cgColor
        button.backgroundColor = .white
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            
            let checkPointNumber: Int = getCheckPointNumber(for: button)
            
            let didChangeCheckpoint = self.didTapOnChooseOnTheMap(checkPointNumber)
            
            if didChangeCheckpoint {
                changeBorderColor(for: button, colorForNotSelected: color)
            }
        }, for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        return button
    }
    
    private func getCheckPointNumber(for button: UIButton) -> Int{
        var checkPointNumber: Int = 0
        self.checkPointsStackView.subviews.enumerated().forEach { (index, view) in
            if view === button {
                checkPointNumber = index
            }
        }
        
        return checkPointNumber
    }
    
    private func changeBorderColor(for button: UIButton, colorForNotSelected: UIColor) {
        if let activeButtonIndex {
            self.checkPointsStackView.subviews[activeButtonIndex].layer.borderColor = colorForNotSelected.cgColor
        }
        
        self.checkPointsStackView.subviews.enumerated().forEach{[weak self] (index, view) in
            if view === button {
                self?.activeButtonIndex = index
            }
        }
    }
    
    private func addLabel(color: UIColor, checkPointNumber: Int, superView: UIView) {
        let label = UILabel()
        label.text = "CheckPoint \(checkPointNumber + 1)"
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        labels.append(label)
        superView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }
    
    private func addImage(color: UIColor, checkPointNumber: Int, superView: UIView) {
        let buttonImage = UIImageView()
        buttonImage.image = UIImage(named: "chooseOnMap")?.withTintColor(color)
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(buttonImage)
        
        
        NSLayoutConstraint.activate([
            buttonImage.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -20),
            buttonImage.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
            buttonImage.heightAnchor.constraint(equalToConstant: 50),
            buttonImage.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func generateRightButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.with(red: 238, green: 238, blue: 235, alpha: 100)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1), for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    private func generateLeftButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    private func generateMainButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

extension MakeCustomTrailViewController: SearchBarViewDelegate {
    func magnifyingGlassPressed() {
        
    }
}

extension MakeCustomTrailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
