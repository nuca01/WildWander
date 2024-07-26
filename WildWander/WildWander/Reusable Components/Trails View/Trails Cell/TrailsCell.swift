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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

    private lazy var wholeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?
    private var willSave: ((_: String?, _: String?, _: Int?) -> Void) = { _, _, _ in }
    private var errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?

    private lazy var imagesFrame: CGRect = {
        let width = UIScreen.main.bounds.width + contentView.safeAreaInsets.left + contentView.safeAreaInsets.right - 40
        let height = UIScreen.main.bounds.height / 4
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        return frame
    }()
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Methods
    private func setUpUI() {
        backgroundColor = .white
        contentView.addSubview(wholeStackView)
        wholeStackView.addArranged(subviews: [imagesCarouselView, bottomStackView])
        bottomStackView.addArranged(subviews: [titleLabel, locationLabel, informationLabel])
        contentView.addSubview(saveButtonView)
        setupConstraints()
        selectionStyle = UITableViewCell.SelectionStyle.none
    }

    private func setupConstraints() {
        setConstraintsForSaveButtonView()
        setConstraintsForWholeStackView()
        setConstraintsToImagesCarouselView()
    }
    
    private func setConstraintsForSaveButtonView() {
        NSLayoutConstraint.activate([
            saveButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            saveButtonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            saveButtonView.heightAnchor.constraint(equalToConstant: 40),
            saveButtonView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setConstraintsForWholeStackView() {
        NSLayoutConstraint.activate([
            wholeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            wholeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wholeStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            wholeStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    private func setConstraintsToImagesCarouselView() {
        NSLayoutConstraint.activate([
            imagesCarouselView.heightAnchor.constraint(equalToConstant: imagesFrame.height),
            imagesCarouselView.widthAnchor.constraint(equalTo: wholeStackView.widthAnchor)
        ])
    }
    
    func updateCellWith(
        imageUrls: [URL?],
        trailTitle: String,
        address: String,
        trailID: Int,
        rating: Double,
        staticMapImage: URL?,
        difficulty: String,
        length: Double,
        isSaved: Bool,
        didTapStaticImage: ((_: Int) -> Void)?,
        didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?,
        errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?
    ) {
        titleLabel.text = trailTitle
        
        locationLabel.text = address
        
        informationLabel.text = "★ \(rating) · \(difficulty) : \(length)km"
        
        saveButtonView.setImage(isSaved ? .trailSaved : .saveTrail, for: .normal)
        
        imagesCarouselView.imageURLs = imageUrls
        imagesCarouselView.staticImageUrl = staticMapImage
        imagesCarouselView.didTapOnStaticImage = didTapStaticImage
        imagesCarouselView.trailId = trailID
        
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
    }
}
