//
//  MakeCustomTrailViewController.swift
//  WildWander
//
//  Created by nuca on 12.07.24.
//

import UIKit

class TrailShownViewController: UIViewController {
    //MARK: - Properties
    lazy var viewModel: TrailShownViewModel = {
        let viewModel = TrailShownViewModel()
        viewModel.onTokenChangedToNil = { [weak self] in
            self?.publishButton.removeFromSuperview()
        }
        
        return viewModel
    }()
    
    //MARK: - addTrailAndChooseTrailStackView
    private lazy var makeTrailAndChooseTrailStackView: UIStackView = {
        let makeTrailAction = UIAction { [weak self] _ in
            guard let self else { return }
            makeTrailAndChooseTrailStackView.removeFromSuperview()
            revertCheckPointStackView()
            configureCustomTrailView()
            if let firstCheckPoint = checkPointsStackView.subviews.first {
                activeButtonIndex = 1
                selectCheckPoint(for: firstCheckPoint)
            }
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
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var checkPointLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "mark up to 25 checkpoints on the map"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .gray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var addRemoveStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
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
            guard let self else { return }
            if checkPointsStackView.subviews.count == 2 {
                removeButton.isEnabled = true
            }
            
            self.addCheckPoint()
            
            scrollToRight()
            
            if checkPointsStackView.subviews.count == 25 {
                button.isEnabled = false
            }
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "minus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            
            if checkPointsStackView.subviews.count == 25 {
                addButton.isEnabled = true
            }
            
            removeCheckPoint()
            
            if checkPointsStackView.subviews.count == 2 {
                button.isEnabled = false
            }
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var checkPointsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    
    private lazy var checkPointsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(checkPointsStackView)
        
        NSLayoutConstraint.activate([
            checkPointsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            checkPointsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            checkPointsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            checkPointsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        
        return scrollView
    }()
    
    private lazy var checkPointsAndAddRemoveStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArranged(subviews: [addRemoveStackView, checkPointsScrollView])
        
        return stackView
    }()
    
    //MARK: - Navigation Views
    private lazy var cancelAndFinishStackView: UIStackView = {
        let finishMakingTrailAction = UIAction { [weak self] _ in
            guard let self else { return }
            customTrailStackView.removeFromSuperview()
            addToMainStackView(customTrailNavigationStackView)
            didTapOnFinishButton()
        }
        return ButtonsStackView(leftTitle: "Cancel", rightTitle: "Finish", leftAction: cancelButtonAction, rightAction: finishMakingTrailAction)
    }()
    
    private lazy var cancelButtonAction: UIAction = UIAction { [weak self] _ in
        guard let self else {return}
        DispatchQueue.main.async { [weak self] in
            self?.customTrailStackView.removeFromSuperview()
            self?.startAndCancelStackView.removeFromSuperview()
        }

        addToMainStackView(makeTrailAndChooseTrailStackView)
        revertCheckPointStackView()
        trailsAdded = false
        didTapOnCancelButton()
    }
    
    private lazy var startAndCancelStackView: UIStackView = {
        return ButtonsStackView(leftTitle: "Cancel", rightTitle: "Start", leftAction: cancelButtonAction, rightAction: startTrailAction)
    }()
    
    private lazy var pauseAndFinishStackView: UIStackView = {
        let pauseNavigationAction = UIAction { [weak self] _ in
            guard let self else { return }
            pauseAndFinishStackView.removeFromSuperview()
            addToMainStackView(resumeAndFinishStackView)
            informationStackView.pauseObserving()
            didTapFinishNavigation()
        }
        
        let pauseAndFinish = ButtonsStackView(leftTitle: "Pause", rightTitle: "Finish", leftAction: pauseNavigationAction, rightAction: finishAction)
        
        let deleteButton = generateAdditionalButtonForStackView(
            title: "Delete",
            action: deleteButtonAction,
            backgroundColor: UIColor.with(red: 183, green: 80, blue: 60, alpha: 30),
            titleColor: UIColor.with(red: 192, green: 35, blue: 0, alpha: 100)
        )
        
        return generateAdditionalStackView(with: pauseAndFinish, and: deleteButton)
    }()
    
    private lazy var deleteButtonAction: UIAction = UIAction { [weak self] _ in
        guard let self else {return}
        informationStackView.deleteActivity()
        DispatchQueue.main.async {
            self.pauseAndFinishStackView.removeFromSuperview()
            self.resumeAndFinishStackView.removeFromSuperview()
        }

        addToMainStackView(makeTrailAndChooseTrailStackView)
        self.trailsAdded = false
        self.didTapFinishNavigation()
        self.didTapOnCancelButton()
    }
    
    lazy var finishAction = UIAction { [weak self] _ in
        guard let self else { return }
        pauseAndFinishStackView.removeFromSuperview()
        resumeAndFinishStackView.removeFromSuperview()
        addToMainStackView(makeTrailAndChooseTrailStackView)
        
        didTapFinishNavigation()
        didTapOnCancelButton()
        informationStackView.finishObserving()
        
        if viewModel.userLoggedIn {
            didFinish(!trailsAdded) { [weak self] trailDetails in
                guard let self else { return }
                if trailsAdded {
                    informationStackView.tryToSaveInformation(trailDetails: nil, trailId: trailID)
                } else {
                    informationStackView.tryToSaveInformation(trailDetails: trailDetails, trailId: nil)
                }
            }
        } else {
            informationStackView.deleteActivity()
        }
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
        
        let resumeAndFinish = ButtonsStackView(leftTitle: "Resume", rightTitle: "Finish", leftAction: resumeNavigationAction, rightAction: finishAction)
        
        let deleteButton = generateAdditionalButtonForStackView(
            title: "Delete",
            action: deleteButtonAction,
            backgroundColor: UIColor.with(red: 183, green: 80, blue: 60, alpha: 30),
            titleColor: UIColor.with(red: 192, green: 35, blue: 0, alpha: 100))
        
        return generateAdditionalStackView(with: resumeAndFinish, and: deleteButton)
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(informationStackView)
        
        return stackView
    }()
    
    private lazy var informationStackView = NavigationInformationStackView()
    
    //MARK: - customTrailNavigationStackView
    private lazy var  publishButton = generateAdditionalButtonForStackView(
        title: "Publish",
        action: publishButtonAction,
        backgroundColor: UIColor.with(red: 222, green: 111, blue: 31, alpha: 100)
    )
    
    private lazy var customTrailNavigationStackView: UIStackView = {
        let editTrailAction = UIAction { [weak self] _ in
            self?.customTrailNavigationStackView.removeFromSuperview()
            self?.configureCustomTrailView()
        }
        
        let editAndStartStackView =  ButtonsStackView(leftTitle: "Edit Trail", rightTitle: "Start Trail", leftAction: editTrailAction, rightAction: startTrailAction)
        
        if viewModel.userLoggedIn {
            return generateAdditionalStackView(with: editAndStartStackView, and: publishButton)
        }
        
        return editAndStartStackView
    }()
    
    lazy var publishButtonAction = UIAction { [weak self] _ in
        guard let self else { return }
        let trailDetails = willPublishTrail()
        informationStackView.publishTrail(trailDetails: trailDetails)
    }
    
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
    
    private var activeButtonIndex: Int? {
        didSet {
            if let activeButtonIndex {
                checkPointsStackView.subviews[activeButtonIndex].layer.borderColor = UIColor.wildWanderGreen.cgColor
            }
        }
    }
    
    private var labels: [UILabel] = []
    
    private var trailsAdded: Bool = false
    
    var trailID: Int?
    
    //MARK: - Closures
    var didTapOnChooseOnTheMap: (_: Int) -> Bool
    
    var didDeleteCheckpoint: (_: Int) -> Int
    
    var didTapOnFinishButton: () -> Void
    
    var didTapOnCancelButton: () -> Void
    
    var willAddCustomTrail: () -> Void
    
    var didTapStartNavigation: () -> Bool
    
    var didTapFinishNavigation: () -> Void
    
    var didFinish: (_: Bool, _: @escaping ((TrailDetails?) -> Void)) -> Void
    
    var didTapAddTrail: () -> Void
    
    var willPublishTrail: () -> TrailDetails
    
    //MARK: - Initializers
    init(didTapOnChooseOnTheMap: (
        @escaping (_: Int) -> Bool),
         didDeleteCheckpoint: (@escaping (_: Int) -> Int),
         didTapOnFinishButton: @escaping () -> Void,
         didTapOnCancelButton: @escaping () -> Void,
         willAddCustomTrail: @escaping () -> Void,
         didTapStartNavigation: @escaping () -> Bool,
         didTapFinishNavigation: @escaping () -> Void,
         didFinish:  @escaping (_: Bool, _: @escaping ((TrailDetails?) -> Void)) -> Void,
         didTapAddTrail: @escaping () -> Void,
         willPublishTrail: @escaping () -> TrailDetails
    ) {
        self.didTapOnChooseOnTheMap = didTapOnChooseOnTheMap
        self.didDeleteCheckpoint = didDeleteCheckpoint
        self.didTapOnFinishButton = didTapOnFinishButton
        self.didTapOnCancelButton = didTapOnCancelButton
        self.willAddCustomTrail = willAddCustomTrail
        self.didTapStartNavigation = didTapStartNavigation
        self.didTapFinishNavigation = didTapFinishNavigation
        self.didFinish = didFinish
        self.didTapAddTrail = didTapAddTrail
        self.willPublishTrail = willPublishTrail
        
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
        _ = didTapFinishNavigation()
    }
    
    func onTrailAdded() {
        trailsAdded = true
    }
    
    private func addSubviews() {
        view.addSubview(mainStackView)
        
        customTrailStackView.addArranged(subviews: [
            checkPointLimitLabel,
            checkPointsAndAddRemoveStackView
        ])
        
        customTrailStackView.setCustomSpacing(5, after: checkPointLimitLabel)
        
        addRemoveStackView.addArranged(subviews: [
            addButton,
            removeButton
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
    
    private func addDefaultTwoCheckpointFields() {
        if checkPointsStackView.subviews.count < 2 {
            addCheckPoint()
            addCheckPoint()
        }
    }
    
    private func revertCheckPointStackView() {
        while (checkPointsStackView.subviews.count > 2) {
            checkPointsStackView.subviews.last?.removeFromSuperview()
        }
        
        removeButton.isEnabled = false
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
            let futureActiveIndex = didDeleteCheckpoint(activeButtonIndex)
            checkPointsStackView.subviews[activeButtonIndex].removeFromSuperview()
            labels.remove(at: activeButtonIndex)
            
            labels.enumerated().forEach { (index, label) in
                labels[index].text = "CheckPoint \(index + 1)"
            }
            self.activeButtonIndex = futureActiveIndex
        }
    }
    
    private func selectCheckPoint(for button: UIView) {
        let checkPointNumber: Int = getCheckPointNumber(for: button)
        
        let didChangeCheckpoint = didTapOnChooseOnTheMap(checkPointNumber)
        
        if didChangeCheckpoint {
            changeBorderColor(for: button)
        }
    }
    
    private func scrollToRight() {
        checkPointsScrollView.layoutIfNeeded()
        let rightOffset = CGPoint(x: self.checkPointsScrollView.contentSize.width - self.checkPointsScrollView.bounds.size.width, y: 0)
        self.checkPointsScrollView.setContentOffset(rightOffset, animated: true)
    }
}

//MARK: - TrailShownViewController
extension TrailShownViewController: SearchBarViewDelegate {
    func magnifyingGlassPressed() {
        
    }
}

//MARK: - UITextFieldDelegate
extension TrailShownViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Constraints
extension TrailShownViewController {
    private func setUpConstraints() {
        constrainMainStackView()
        constrainCheckPointsScrollView()
        constrainAddAndRemoveButtons()
        constrainCheckPointsAndAddRemoveStackView()
    }
    
    private func constrainMainStackView() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
        ])
    }
    private func addToMainStackView(_ view: UIView) {
        mainStackView.addArrangedSubview(view)
    }
    
    private func constrainCheckPointsAndAddRemoveStackView() {
        NSLayoutConstraint.activate([
            checkPointsAndAddRemoveStackView.leadingAnchor.constraint(equalTo: customTrailStackView.leadingAnchor),
            checkPointsAndAddRemoveStackView.trailingAnchor.constraint(equalTo: customTrailStackView.trailingAnchor),
        ])
    }
    
    private func constrainCheckPointsScrollView() {
        NSLayoutConstraint.activate([
            checkPointsScrollView.leadingAnchor.constraint(equalTo: addRemoveStackView.trailingAnchor, constant: 10),
            checkPointsScrollView.trailingAnchor.constraint(equalTo: checkPointsAndAddRemoveStackView.trailingAnchor),
            checkPointsScrollView.heightAnchor.constraint(equalToConstant: 70)
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
}

//MARK: - Generate Views
extension TrailShownViewController {
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
        button.layer.borderColor =  UIColor.wildWanderExtraLightGray.cgColor
        button.backgroundColor = .white
        
        button.addAction(UIAction { [weak self] _ in
            self?.selectCheckPoint(for: button)
        }, for: .touchUpInside)
        
        button.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 70),
            button.widthAnchor.constraint(equalToConstant: 140)
        ])
        
        return button
    }
    
    //MARK: - Helper Methods
    private func getCheckPointNumber(for button: UIView) -> Int{
        var checkPointNumber: Int = 0
        self.checkPointsStackView.subviews.enumerated().forEach { (index, view) in
            if view === button {
                checkPointNumber = index
            }
        }
        return checkPointNumber
    }
    
    private func changeBorderColor(for button: UIView) {
        if let activeButtonIndex {
            self.checkPointsStackView.subviews[activeButtonIndex].layer.borderColor =  UIColor.wildWanderExtraLightGray.cgColor
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
            label.topAnchor.constraint(equalTo: superView.topAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        ])
    }
    
    private func addImage(checkPointNumber: Int, superView: UIView) {
        let buttonImage = UIImageView()
        buttonImage.image = UIImage(named: "chooseOnMap")?.withTintColor(UIColor.wildWanderGreen)
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(buttonImage)
        
        NSLayoutConstraint.activate([
            buttonImage.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -10),
            buttonImage.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            buttonImage.heightAnchor.constraint(equalToConstant: 25),
            buttonImage.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func generateAdditionalStackView(with stackView: UIStackView, and button: UIButton) -> UIStackView {
        let deleteStackView = UIStackView()
        deleteStackView.alignment = .center
        deleteStackView.spacing = 20
        deleteStackView.axis = .vertical
        deleteStackView.distribution = .fill
        
        deleteStackView.addArranged(subviews: [stackView, button])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: deleteStackView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: deleteStackView.trailingAnchor),
        ])
        
        deleteStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return deleteStackView
    }
    
    private func generateAdditionalButtonForStackView(
        title: String,
        action: UIAction,
        backgroundColor: UIColor? = nil,
        titleColor: UIColor? = nil
    ) -> UIButton {
        let deleteButton = UIButton.wildWanderGreenButton(titled: title)
        deleteButton.addAction(action, for: .touchUpInside)
        
        if let backgroundColor {
            deleteButton.backgroundColor = backgroundColor
        }
        
        if let titleColor {
            deleteButton.setTitleColor(titleColor, for: .normal)
        }
        
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        return deleteButton
    }
}
