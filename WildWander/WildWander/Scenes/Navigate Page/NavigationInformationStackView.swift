//
//  NavigationInformationStackView.swift
//  WildWander
//
//  Created by nuca on 15.07.24.
//

import UIKit
import CoreLocation

class NavigationInformationStackView: UIStackView {
    private lazy var timeValueLabel: UILabel = generateTitleLabel(with: "0:0", and: 23)
    private lazy var distanceValueLabel: UILabel = generateTitleLabel(with: "0,00m", and: 23)
    private lazy var elevationGainValueLabel: UILabel = generateTitleLabel(with: "0,00m", and: 23)
    private lazy var locationManager = {
        let locationManager =  CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        
        return locationManager
    }()
    
    private var distanceTravelled: CLLocationDistance = 0.0
    private var startTime: Date?
    private var timer: Timer?
    private var pauseTime: Date?
    private var justStarted: Bool = true
    private var lastAltitude: CLLocationDistance?
    private var elevationGain: CLLocationDistance = 0.0
    
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
    
    deinit {
        stopTimer()
    }
    
    func startObserving() {
        nullifyProperties()
        startTime = Date()
        startTimer()
        locationManager.startUpdatingLocation()
    }
    
    func finishObserving() {
        startTime = nil
        stopTimer()
        locationManager.stopUpdatingLocation()
    }
    
    func pauseObserving() {
        pauseTime = Date()
        stopTimer()
        locationManager.stopUpdatingLocation()
    }
    
    func resumeObserving() {
        startTime = Date().addingTimeInterval(-Date().timeIntervalSince(pauseTime ?? Date()))
        pauseTime = nil
        startTimer()
        justStarted = true
        locationManager.startUpdatingLocation()
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
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatDistance(metres: Double) -> String {
        if metres >= 1000 {
            String(format: "%.2fkm", metres / 1000)
        } else {
            String(format: "%.2fm", metres)
        }
    }
    
    private func nullifyProperties() {
        distanceTravelled = 0.0
        justStarted = true
        lastAltitude = nil
        elevationGain = 0.0
    }

    @objc private func updateTimeLabel() {
        guard let startTime = startTime else { return }
        let elapsedTime = Date().timeIntervalSince(startTime)
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        timeValueLabel.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

extension NavigationInformationStackView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let currentAltitude = lastLocation.altitude
            
            if !justStarted {
                elevationGain += (lastAltitude ?? 0.0) - lastLocation.altitude
                elevationGainValueLabel.text = formatDistance(metres: elevationGain)
                
                distanceTravelled += 50
                distanceValueLabel.text = formatDistance(metres: distanceTravelled)
            } else {
                justStarted = false
            }
            
            lastAltitude = currentAltitude
        }
    }
}
