//
//  MakeCustomTrailView.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit

class MakeCustomTrailViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
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
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.1, alpha: 1)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addAction(UIAction { [weak self] _ in
            self?.didTapOnFinishButton()
        }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
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
    
    init(didTapOnChooseOnTheMap: (@escaping (_: Int) -> Bool), didDeleteCheckpoint: (@escaping (_: Int) -> Int), didTapOnFinishButton: @escaping () -> Void) {
        self.didTapOnChooseOnTheMap = didTapOnChooseOnTheMap
        self.didDeleteCheckpoint = didDeleteCheckpoint
        self.didTapOnFinishButton = didTapOnFinishButton
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        view.backgroundColor = .white
        setUpConstraints()
        addCheckPoint()
        addCheckPoint()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        [checkPointsStackView, addRemoveStackView, finishButton].forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        [addButton, removeButton].forEach { view in
            addRemoveStackView.addArrangedSubview(view)
        }
        
    }
    
    private func setUpConstraints() {
        constrainScrollView()
        constrainStackView()
        constrainCheckPointsStackView()
        constrainAddAndRemoveButtons()
        
        NSLayoutConstraint.activate([
            finishButton.heightAnchor.constraint(equalToConstant: 50),
            finishButton.widthAnchor.constraint(equalTo: finishButton.titleLabel!.widthAnchor, constant: 20)
        ])
    }
    
    private func constrainScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func constrainStackView() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    private func constrainCheckPointsStackView() {
        NSLayoutConstraint.activate([
            checkPointsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            checkPointsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
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
            
            var checkPointNumber: Int = getCheckPointNumber(for: button)
            
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
}
