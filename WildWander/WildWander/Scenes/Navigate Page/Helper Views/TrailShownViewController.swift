//
//  MakeCustomTrailViewController.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit

class TrailShownViewController: UIViewController {
    //MARK: - Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    //MARK: - addTrailAndChooseTrailStackView
    private lazy var makeTrailAndChooseTrailStackView: UIStackView = {
        let makeTrailAction = UIAction { [weak self] _ in
            guard let self else { return }
            makeTrailAndChooseTrailStackView.removeFromSuperview()
            configureCustomTrailView()
        }
        
        let chooseTrailAction = UIAction { [weak self] _ in
            self?.didTapAddTrail()
        }
        
        return ButtonsStackView(leftTitle: "Make Trail", rightTitle: "Choose Trail", leftAction: makeTrailAction, rightAction: chooseTrailAction)
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
    
    private lazy var cancelAndFinishStackView: UIStackView = {
        let finishMakingTrailAction = UIAction { [weak self] _ in
            guard let self else { return }
            customTrailStackView.removeFromSuperview()
            addToMainStackView(customTrailNavigationStackView)
            didTapOnFinishButton()
        }
        return ButtonsStackView(leftTitle: "Finish", rightTitle: "Cancel", leftAction: finishMakingTrailAction, rightAction: cancelButtonAction)
    }()
    
    private lazy var cancelButtonAction: UIAction = UIAction { [weak self] _ in
        guard let self else {return}
        DispatchQueue.main.async {
            self.customTrailStackView.removeFromSuperview()
            self.startAndCancelStackView.removeFromSuperview()
        }

        addToMainStackView(makeTrailAndChooseTrailStackView)
        self.trailsAdded = false
        self.didTapOnCancelButton()
    }
    
    private lazy var startAndCancelStackView: UIStackView = {
        return ButtonsStackView(leftTitle: "Start", rightTitle: "Cancel", leftAction: startTrailAction, rightAction: cancelButtonAction)
    }()
    
    private lazy var pauseAndFinishStackView: UIStackView = {
        let pauseNavigationAction = UIAction { [weak self] _ in
            guard let self else { return }
            pauseAndFinishStackView.removeFromSuperview()
            addToMainStackView(resumeAndFinishStackView)
            informationStackView.pauseObserving()
            didTapFinishNavigation()
        }
        return ButtonsStackView(leftTitle: "Finish", rightTitle: "Pause", leftAction: finishNavigationAction, rightAction: pauseNavigationAction)
    }()
    
    lazy var finishNavigationAction = UIAction { [weak self] _ in
        guard let self else { return }
        pauseAndFinishStackView.removeFromSuperview()
        resumeAndFinishStackView.removeFromSuperview()
        addToMainStackView(makeTrailAndChooseTrailStackView)
        informationStackView.finishObserving()
        didTapFinishNavigation()
    }
    
    private lazy var resumeAndFinishStackView: UIStackView = {
        let resumeNavigationAction = UIAction { [weak self] _ in
            guard let self else { return }
            if didTapStartNavigation() {
                resumeAndFinishStackView.removeFromSuperview()
                addToMainStackView(pauseAndFinishStackView)
                informationStackView.resumeObserving()
            }
        }
        return ButtonsStackView(leftTitle: "Finish", rightTitle: "Resume", leftAction: finishNavigationAction, rightAction: resumeNavigationAction)
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(informationStackView)
        
        return stackView
    }()
    
    private lazy var informationStackView = NavigationInformationStackView()
    //MARK: - customTrailNavigationStackView
    private lazy var customTrailNavigationStackView: UIStackView = {
        let editTrailAction = UIAction { [weak self] _ in
            self?.customTrailNavigationStackView.removeFromSuperview()
            self?.configureCustomTrailView()
        }
        
        return ButtonsStackView(leftTitle: "Edit Trail", rightTitle: "Start Trail", leftAction: editTrailAction, rightAction: startTrailAction)
    }()
    
    lazy var startTrailAction = UIAction { [weak self] _ in
        guard let self else { return }
        if didTapStartNavigation() {
            trailsAdded = false
            startAndCancelStackView.removeFromSuperview()
            customTrailNavigationStackView.removeFromSuperview()
            addToMainStackView(pauseAndFinishStackView)
            informationStackView.startObserving()
        }
    }
    
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
    
    private var trailsAdded: Bool = false
    
    //MARK: - Closures
    var didTapOnChooseOnTheMap: (_: Int) -> Bool
    
    var didDeleteCheckpoint: (_: Int) -> Int
    
    var didTapOnFinishButton: () -> Void
    
    var didTapOnCancelButton: () -> Void
    
    var willAddCustomTrail: () -> Void
    
    var didTapStartNavigation: () -> Bool
    
    var didTapFinishNavigation: () -> Void
    
    var didTapAddTrail: () -> Void
    
    //MARK: - Initializers
    init(didTapOnChooseOnTheMap: (
        @escaping (_: Int) -> Bool),
         didDeleteCheckpoint: (@escaping (_: Int) -> Int),
         didTapOnFinishButton: @escaping () -> Void,
         didTapOnCancelButton: @escaping () -> Void,
         willAddCustomTrail: @escaping () -> Void,
         didTapStartNavigation: @escaping () -> Bool,
         didTapFinishNavigation: @escaping () -> Void,
         didTapAddTrail: @escaping () -> Void
    ) {
        self.didTapOnChooseOnTheMap = didTapOnChooseOnTheMap
        self.didDeleteCheckpoint = didDeleteCheckpoint
        self.didTapOnFinishButton = didTapOnFinishButton
        self.didTapOnCancelButton = didTapOnCancelButton
        self.willAddCustomTrail = willAddCustomTrail
        self.didTapStartNavigation = didTapStartNavigation
        self.didTapFinishNavigation = didTapFinishNavigation
        self.didTapAddTrail = didTapAddTrail
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        
        addToMainStackView(makeTrailAndChooseTrailStackView)
        
        setUpConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if trailsAdded {
            cancelAnyPreviousActivity()
            
            addToMainStackView(startAndCancelStackView)
        }
    }
    
    //MARK: - Methods
    private func cancelAnyPreviousActivity() {
        makeTrailAndChooseTrailStackView.removeFromSuperview()
        customTrailStackView.removeFromSuperview()
        customTrailNavigationStackView.removeFromSuperview()
        pauseAndFinishStackView.removeFromSuperview()
        resumeAndFinishStackView.removeFromSuperview()
        informationStackView.finishObserving()
        didTapFinishNavigation()
    }
    
    func onTrailAdded() {
        trailsAdded = true
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(mainStackView)
        
        customTrailStackView.addArranged(subviews: [
            checkPointsStackView,
            addRemoveStackView,
        ])
        
        addRemoveStackView.addArranged(subviews: [
            addButton,
            removeButton
        ])
    }
    
    private func setUpConstraints() {
        constrainScrollView()
        constrainMainStackView()
        constrainCheckPointsStackView()
        constrainAddAndRemoveButtons()
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    //MARK: - configure CustomTrailView
    private func configureCustomTrailView() {
        willAddCustomTrail()
        
        addSubViewsOfCustomTrailView()
        
        addToMainStackView(customTrailStackView)
        
        addDefaultTwoCheckpointFields()
        
        constrainCancelAndFinishStackView(to: customTrailStackView)
    }
    
    private func addSubViewsOfCustomTrailView() {
        
        cancelAndFinishStackView.removeFromSuperview()
        customTrailStackView.addArranged(subviews: [
            cancelAndFinishStackView
        ])
    }
    
    
    private func constrainScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -view.safeAreaInsets.top),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func addToMainStackView(_ view: UIView) {
        mainStackView.addArrangedSubview(view)
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
    
    private func constrainCancelAndFinishStackView(to view: UIView) {
        
        NSLayoutConstraint.activate([
            cancelAndFinishStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cancelAndFinishStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func addDefaultTwoCheckpointFields() {
        if checkPointsStackView.subviews.count < 2 {
            addCheckPoint()
            addCheckPoint()
        }
    }
    
    //MARK: - Button Actions
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
    
    private func selectCheckPoint(for button: UIButton) {
        let checkPointNumber: Int = getCheckPointNumber(for: button)
        
        let didChangeCheckpoint = didTapOnChooseOnTheMap(checkPointNumber)
        
        if didChangeCheckpoint {
            changeBorderColor(for: button)
        }
    }
    
    //MARK: - Generate Views
    private func generateCheckPointButton() -> UIButton {
        let checkPointNumber = self.checkPointsStackView.subviews.count
        
        let button = generateButtonForCheckPointButton()
        
        addLabel(checkPointNumber: checkPointNumber, superView: button)
        
        addImage(checkPointNumber: checkPointNumber, superView: button)
        
        return button
    }
    
    private func generateButtonForCheckPointButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.layer.borderWidth = 3
        button.layer.borderColor =  UIColor.wildWanderGreen.cgColor
        button.backgroundColor = .white
        
        button.addAction(UIAction { [weak self] _ in
            self?.selectCheckPoint(for: button)
        }, for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        return button
    }
    
    //MARK: - Helper Methods
    private func getCheckPointNumber(for button: UIButton) -> Int{
        var checkPointNumber: Int = 0
        self.checkPointsStackView.subviews.enumerated().forEach { (index, view) in
            if view === button {
                checkPointNumber = index
            }
        }
        return checkPointNumber
    }
    
    private func changeBorderColor(for button: UIButton) {
        if let activeButtonIndex {
            self.checkPointsStackView.subviews[activeButtonIndex].layer.borderColor =  UIColor.wildWanderGreen.cgColor
        }
        
        self.checkPointsStackView.subviews.enumerated().forEach{[weak self] (index, view) in
            if view === button {
                self?.activeButtonIndex = index
            }
        }
    }
    
    private func addLabel(checkPointNumber: Int, superView: UIView) {
        let label = UILabel()
        label.text = "CheckPoint \(checkPointNumber + 1)"
        label.textColor = .wildWanderGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        labels.append(label)
        superView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }
    
    private func addImage(checkPointNumber: Int, superView: UIView) {
        let buttonImage = UIImageView()
        buttonImage.image = UIImage(named: "chooseOnMap")?.withTintColor(UIColor.wildWanderGreen)
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

extension TrailShownViewController: SearchBarViewDelegate {
    func magnifyingGlassPressed() {
        
    }
}

extension TrailShownViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
