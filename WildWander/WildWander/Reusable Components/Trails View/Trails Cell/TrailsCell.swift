//
//  TrailsCell.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import UIKit

class TrailsCell: UITableViewCell {
    //MARK: - Properties
    static let identifier = "TrailsCell"
    
    private var viewModel = TrailsCellViewModel()
    
    private lazy var imagesCarouselView: ImageCarouselView = {
        let imagesFrame = CGRect(x: 0, y: 0, width: imagesFrame.width, height: imagesFrame.height)
        let images = ImageCarouselView(frame: imagesFrame, imageURLs: [])
        images.layer.masksToBounds = true
        images.layer.cornerRadius = imagesFrame.height / 20
        images.translatesAutoresizingMaskIntoConstraints = false
        return images
    }()
    
    private var titleLabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.text = "unavailable"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.text = "unavailable"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var informationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.text = "unavailable"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var nameAndLocationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var saveButtonView: UIButton = {
        let button = UIButton()
        button.setImage(.saveTrail, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if viewModel.isSignedIn {
                if button.imageView?.image === UIImage.saveTrail {
                    button.setImage(.trailSaved, for: .normal)
                    didTapSave?(willSave)
                } else {
                    button.setImage(.saveTrail, for: .normal)
                    willSave(nil, nil, nil)
                }
            } else {
                errorDidHappen?(
                    "You are not signed in",
                    "Please sign in to be able to save trails",
                    nil,
                    "Understood",
                    nil
                )
            }
        }, for: .touchUpInside)
        
        return button
    }()
//    private var downloadButtonView: UIButton = {
//        let button = UIButton()
//        button.setImage(.download, for: .normal)
//        button.tintColor = .wildWanderGreen
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private var nameLocationAndDownloadStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fill
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
    
    private var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var wholeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var imagesFrame: CGRect = {
        let width = UIScreen.main.bounds.width + contentView.safeAreaInsets.left + contentView.safeAreaInsets.right - 40
        let height = UIScreen.main.bounds.height / 4
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        return frame
    }()
    
    var didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?
    
    private var willSave: ((_: String?, _: String?, _: Int?) -> Void) = { _, _, _ in
        
    }
    
    private var errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?
    
    //MARK: - Initilizers
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }
    
    private func setUpUI() {
        backgroundColor = .white
        addSubViews()
        addConstraints()
        contentView.isUserInteractionEnabled = true
        wholeStackView.isUserInteractionEnabled = true
    }
    
    private func addSubViews() {
        contentView.addSubview(wholeStackView)
        contentView.addSubview(saveButtonView)
        wholeStackView.addArranged(subviews: [imagesCarouselView, bottomStackView])
        nameAndLocationStackView.addArranged(subviews: [titleLabel, locationLabel])
        bottomStackView.addArranged(subviews: [nameAndLocationStackView, informationLabel])
    }
    
    private func addConstraints() {
        constrainSaveButtonView()
        constrainWholeStackView()
        constrainBottomStackView()
        ConstrainImagesCarouselView()
        constrainLabels()
    }
    
    private func constrainSaveButtonView() {
        NSLayoutConstraint.activate([
            saveButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            saveButtonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            saveButtonView.heightAnchor.constraint(equalToConstant: 40),
            saveButtonView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func constrainLabels() {
        [titleLabel, locationLabel, informationLabel]
            .forEach { label in
                NSLayoutConstraint.activate([
                    label.widthAnchor.constraint(equalToConstant: imagesFrame.width)
                ])
            }
    }
    
    private func constrainBottomStackView() {
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: wholeStackView.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: wholeStackView.trailingAnchor),
        ])
    }
    
    private func constrainWholeStackView() {
        NSLayoutConstraint.activate([
            wholeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            wholeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wholeStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            wholeStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    private func ConstrainImagesCarouselView() {
        NSLayoutConstraint.activate([
            self.imagesCarouselView.heightAnchor.constraint(equalToConstant: imagesFrame.height),
            self.imagesCarouselView.widthAnchor.constraint(equalToConstant: imagesFrame.width),
            self.imagesCarouselView.centerXAnchor.constraint(equalTo: wholeStackView.centerXAnchor),
        ])
    }
    
    private func updateImagesCarouselViewImages(with imageURLs: [URL?]) {
        self.imagesCarouselView.imageURLs = imageURLs
    }
    
    private func formatInformationTextLabelWith(rating: Double, difficulty: String, length: Double) {
        let text = "★ \(rating) · \(difficulty) : \(length)km"
        
        informationLabel.text = text
    }
    
    //MARK: - Methods
    func updateCellWith(
        imageUrls: [URL?],
        trailID: Int,
        trailTitle: String,
        address: String,
        rating: Double,
        difficulty: String,
        length: Double,
        isSaved: Bool,
        didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?,
        errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?
    ) {
        self.didTapSave = didTapSave
        
        willSave = { [weak self] (name, description, savedListId) in
            self?.viewModel.save(saveTrailModel: SaveTrail(
                name: name,
                description: description,
                savedListId: savedListId,
                trailId: trailID
            ))
        }
        
        self.errorDidHappen = errorDidHappen
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            titleLabel.text = trailTitle
            locationLabel.text = address
            formatInformationTextLabelWith(
                rating: rating,
                difficulty: difficulty,
                length: length
            )
            
            if isSaved {
                saveButtonView.setImage(.trailSaved, for: .normal)
            } else {
                saveButtonView.setImage(.saveTrail, for: .normal)
            }
            
            updateImagesCarouselViewImages(with: imageUrls)
        }
    }
}
