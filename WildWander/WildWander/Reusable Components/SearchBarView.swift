//
//  SearchBarView.swift
//  WildWander
//
//  Created by nuca on 08.07.24.
//

import UIKit

protocol SearchBarViewDelegate: AnyObject {
    func magnifyingGlassPressed()
}

class SearchBarView: UITextField {
    weak var searchBarDelegate: SearchBarViewDelegate?
    
    //MARK: - Initializers
    init(rightView: UIView? = nil) {
        super.init(frame: .zero)
        
        setRightView(rightView)
        
        setupDefaultProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaultProperties()
    }
    
    //MARK: - Methods
    private func setupDefaultProperties() {
        setLeftView()
        
        setBackgroundColor()
        
        setTextColor()
        
        setupHeightConstraint(60)
        
        setCornerRadius(25)
        
        setPlaceholder()
        
        setFont()
    }
    
    //MARK: - Helper Methods
    private func setRightView(_ rightView: UIView?) {
        self.rightView = rightView ?? UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        self.rightViewMode = .always
    }
    
    private func setLeftView() {
        let image = UIImage(named: "magnifingGlass")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 22),
            imageView.widthAnchor.constraint(equalToConstant: 52)
        ])
        
        imageView.tintColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(magnifyingGlassTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        leftView = imageView
        
        leftViewMode = .always
    }
    
    private func setBackgroundColor() {
        backgroundColor = UIColor.with(red: 239, green: 239, blue: 236, alpha: 96.61)
    }
    
    private func setTextColor() {
        textColor = UIColor.with(red: 108, green: 118, blue: 101, alpha: 100)
    }
    
    private func setupHeightConstraint(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func setCornerRadius(_ value: CGFloat) {
        layer.cornerRadius = value
    }
    
    private func setPlaceholder() {
        placeholder = "Find locations"
    }
    
    private func setFont() {
        font = UIFont.systemFont(ofSize: 20)
    }
    
    @objc private func magnifyingGlassTapped() {
        searchBarDelegate?.magnifyingGlassPressed()
    }
}
