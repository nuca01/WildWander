//
//  ViewController.swift
//  WildWander
//
//  Created by nuca on 01.07.24.
//

import UIKit

class ViewController: UIViewController {
    // example of using  ImageCarouselView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width / 3, height: view.frame.height / 3)
        let imageNames = ["image1", "image2", "image3"]
        let pagedImageView = ImageCarouselView(frame: frame, images: imageNames)
        
        pagedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pagedImageView)
        
        NSLayoutConstraint.activate([
            pagedImageView.heightAnchor.constraint(equalToConstant: view.frame.height / 3),
            pagedImageView.widthAnchor.constraint(equalToConstant: view.frame.width / 3),
            pagedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pagedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
