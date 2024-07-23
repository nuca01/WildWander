//
//  NavigationInformationStackView.swift
//  WildWander
//
//  Created by nuca on 15.07.24.
//

import UIKit
import CoreLocation

class NavigationInformationStackView: UIStackView {
    //MARK: - Properties
    private lazy var timeValueLabel: UILabel = generateTitleLabel(with: "0:0", and: 23)
    private lazy var distanceValueLabel: UILabel = generateTitleLabel(with: "0,00m", and: 23)
    private lazy var elevationGainValueLabel: UILabel = generateTitleLabel(with: "0,00m", and: 23)
    private lazy var locationManager = {
        let locationManager =  CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        return locationManager
    }()
    
    private lazy var viewModel = {
        let viewModel = NavigationInformationStackViewModel()
        viewModel.timeDidChangeTo = { [weak self] time in
            self?.timeValueLabel.text = time
        }
        
        return viewModel
    }()
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        alignment = .center
        distribution = .equalCentering
        addArranged(subviews: [
            generateStackView(with: "Time", and: timeValueLabel),
            generateStackView(with: "Distance", and: distanceValueLabel),
            generateStackView(with: "Elev. gain", and: elevationGainValueLabel)
        ])
        
        locationManager.delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Deinitializer
    deinit {
        viewModel.stopTimer()
    }
    
    //MARK: - Methods
    func startObserving() {
        viewModel.startObserving()
        locationManager.startUpdatingLocation()
    }
    
    func finishObserving() {
        viewModel.finishObserving()
        locationManager.stopUpdatingLocation()
    }
    
    func pauseObserving() {
        viewModel.pauseObserving()
        locationManager.stopUpdatingLocation()
    }
    
    func resumeObserving() {
        viewModel.resumeObserving()
        locationManager.startUpdatingLocation()
    }
    
    func deleteActivity() {
        viewModel.deleteActivity()
        timeValueLabel.text = "0:0"
        distanceValueLabel.text = "0,00m"
        elevationGainValueLabel.text = "0,00m"
        locationManager.stopUpdatingLocation()
    }
    
    func tryToSaveInformation(polyLine: String?, trailId: Int?) {
        viewModel.completeTrail(polyLine: polyLine, trailId: trailId)
    }
    
    private func generateStackView(with title: String, and valueLabel: UILabel) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArranged(subviews: [generateTitleLabel(with: title), valueLabel])
        
        return stackView
    }
    
    private func generateTitleLabel(with title: String, and size: CGFloat = 12) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: size)
        label.textColor = .wildWanderGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

//MARK: - CLLocationManagerDelegate
extension NavigationInformationStackView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let currentAltitude = lastLocation.altitude
            
            if !viewModel.justStarted {
                viewModel.elevationGain += (viewModel.lastAltitude ?? 0.0) - lastLocation.altitude
                elevationGainValueLabel.text = viewModel.formatDistance(metres: viewModel.elevationGain)
                
                viewModel.distanceTravelled += 10
                distanceValueLabel.text = viewModel.formatDistance(metres: viewModel.distanceTravelled)
            } else {
                viewModel.justStarted = false
            }
            
            viewModel.lastAltitude = currentAltitude
        }
    }
}
