//
//  ListCell.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import Foundation
import UIKit

class ListCell: UITableViewCell {
    //MARK: - Properties
    static let identifier = "ListCell"
    
    private var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    private var titleLabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var trailCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var titleAndCountStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var wholeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        addConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(wholeStackView)
        titleAndCountStackView.addArranged(subviews: [titleLabel, trailCountLabel])
        wholeStackView.addArranged(subviews: [cellImageView, titleAndCountStackView])
        
    }
    
    private func addConstraints() {
        constrainCellImageView()
        constrainWholeStackView()
    }
    
    private func constrainCellImageView() {
        NSLayoutConstraint.activate([
            cellImageView.heightAnchor.constraint(equalToConstant: 55),
            cellImageView.widthAnchor.constraint(equalToConstant: 55),
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.contentMode = .scaleAspectFit
        cellImageView.image = nil
        titleAndCountStackView.addArrangedSubview(trailCountLabel)
        titleLabel.textColor = .black
    }
    
    //MARK: - Methods
    func updateCellWith(
        title: String,
        trailCount: Int,
        imageUrl: URL?
    ) {
        titleLabel.text = title
        if let imageUrl {
            cellImageView.load(url: imageUrl)
        } else {
            cellImageView.image = UIImage(named: "savedList")
        }
        cellImageView.contentMode = .scaleToFill
        trailCountLabel.text = "\(trailCount) trails"
    }
    
    func updateCellAsCreateAList() {
        titleLabel.text = "Create a List"
        cellImageView.image = UIImage(named: "addList")
        titleLabel.textColor = .wildWanderGreen
        trailCountLabel.removeFromSuperview()
    }
}
