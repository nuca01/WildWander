//
//  NavigationInformationStackViewModel.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation
import CoreLocation

class NavigationInformationStackViewModel {
    //MARK: - Properties
    private var startTime: Date?
    private var timer: Timer?
    private var pauseTime: Date?
    var distanceTravelled: CLLocationDistance = 0.0
    var justStarted: Bool = true
    var lastAltitude: CLLocationDistance?
    var elevationGain: CLLocationDistance = 0.0
    
    var timeDidChangeTo: ((_: String) -> Void)?
    
    //MARK: - Deinitializer
    deinit {
        stopTimer()
    }
    
    //MARK: - Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func formatDistance(metres: Double) -> String {
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
        let time = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        timeDidChangeTo?(time)
    }
    
    func startObserving() {
        nullifyProperties()
        startTime = Date()
        startTimer()
    }
    
    func finishObserving() {
        startTime = nil
        stopTimer()
    }
    
    func pauseObserving() {
        pauseTime = Date()
        stopTimer()
    }
    
    func resumeObserving() {
        startTime = Date().addingTimeInterval(-Date().timeIntervalSince(pauseTime ?? Date()))
        pauseTime = nil
        startTimer()
        justStarted = true
    }
    
    func deleteActivity() {
        nullifyProperties()
        finishObserving()
    }
}
