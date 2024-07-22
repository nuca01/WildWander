//
//  UIImageView.swift
//  WildWander
//
//  Created by nuca on 09.07.24.
//

import UIKit
import SwiftUI

extension UIImageView {
    func load(url: URL) {
        let loaderView = addLoader()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        loaderView?.removeFromSuperview()
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func addLoader() -> UIView? {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        if let loaderView {
            addSubview(loaderView)
            NSLayoutConstraint.activate([
                loaderView.heightAnchor.constraint(equalToConstant: 20),
                loaderView.widthAnchor.constraint(equalToConstant: 20),
                loaderView.centerYAnchor.constraint(equalTo: centerYAnchor),
                loaderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
        }
        return loaderView
    }
}
