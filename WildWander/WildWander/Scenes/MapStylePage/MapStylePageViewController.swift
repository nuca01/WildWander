//
//  MapStylePageViewController.swift
//  WildWander
//
//  Created by nuca on 10.07.24.
//

import UIKit
import MapboxMaps

final class MapStylePageViewController: UIViewController {
    //MARK: - Properties
    private var mapStyle: MapboxMaps.StyleURI
    private var didChangeStyleTo: (_ style: MapboxMaps.StyleURI) -> Void
    private var sheetDidDisappear: () -> Void
    
    private lazy var changeToSatelliteButton: UIButton = {
        let button = generateButton(for: .satellite)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            if self?.mapStyle == .outdoors {
                self?.set(to: .satellite)
            }
        }), for: .touchUpInside)
        
        button.setImage(UIImage(named: "satellite"), for: .normal)
        
        return button
    }()
    
    private lazy var changeToOutdoorsButton: UIButton = {
        let button = generateButton(for: .outdoors)
        
        button.addAction(UIAction(handler: { [weak self] _ in
            if self?.mapStyle == .satellite {
                self?.set(to: .outdoors)
            }
        }), for: .touchUpInside)
        
        button.setImage(UIImage(named: "outdoors"), for: .normal)
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleAndButtonStackView(from: changeToOutdoorsButton),
            titleAndButtonStackView(from: changeToSatelliteButton)
        ])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sheetDidDisappear()
    }
    //MARK: - Methods
    private func generateButton(for style: MapboxMaps.StyleURI) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.layer.borderWidth = 5
        button.layer.borderColor = style == mapStyle ? UIColor.black.cgColor: UIColor.clear.cgColor
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }
    
    private func set(to style: MapboxMaps.StyleURI) {
        mapStyle = style
        changeToOutdoorsButton.layer.borderColor = style == .outdoors ? UIColor.black.cgColor: UIColor.clear.cgColor
        changeToSatelliteButton.layer.borderColor = style == .satellite ? UIColor.black.cgColor: UIColor.clear.cgColor
        didChangeStyleTo(style)
    }
    
    private func setUpViews() {
        view.addSubview(stackView)
        
        constrainStackView()
        
        constrainButtons()
    }
    
    //MARK: - Helper Methods
    private func constrainStackView() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func constrainButtons() {
        [changeToOutdoorsButton, changeToSatelliteButton]
            .forEach { button in
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: (view.bounds.width - 60) / 2),
                button.heightAnchor.constraint(equalToConstant: 140)
            ])
        }
    }
    
    private func titleAndButtonStackView(from button: UIButton) -> UIStackView {
        let label = UILabel()
        label.text = button === changeToOutdoorsButton ? "Outdoors": "Satellite"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        
        let stackView = UIStackView(arrangedSubviews: [button, label])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        
        return stackView
    }

    //MARK: - Initializers
    init(
        mapStyle: MapboxMaps.StyleURI,
        didChangeStyleTo: @escaping (MapboxMaps.StyleURI) -> Void,
        sheetDidDisappear: @escaping () -> Void
    ) {
        self.mapStyle = mapStyle
        self.didChangeStyleTo = didChangeStyleTo
        self.sheetDidDisappear = sheetDidDisappear
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
