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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var informationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.wildWanderGreen
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
        let height = UIScreen.main.bounds.height / 3
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        return frame
    }()
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
        contentView.isUserInteractionEnabled = true
        wholeStackView.isUserInteractionEnabled = true
    }
    
    private func addSubViews() {
        contentView.addSubview(wholeStackView)
        constrainWholeStackView()
        wholeStackView.addArranged(subviews: [imagesCarouselView, bottomStackView])
        nameAndLocationStackView.addArranged(subviews: [titleLabel, locationLabel])
        bottomStackView.addArranged(subviews: [nameAndLocationStackView, informationLabel])
        constrainBottomStackView()
        ConstrainImagesCarouselView()
        constrainLabels()
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
        length: Double
    ) {
        
        DispatchQueue.main.async { [weak self] in
            self?.updateImagesCarouselViewImages(with: imageUrls)
            self?.titleLabel.text = trailTitle
            self?.locationLabel.text = address
            self?.formatInformationTextLabelWith(
                rating: rating,
                difficulty: difficulty,
                length: length
            )
        }
    }
}
