//
//  TrailShownViewModel.swift
//  WildWander
//
//  Created by nuca on 23.07.24.
//

import Foundation

class TrailShownViewModel {
    private var token: String? {
        KeychainHelper.retrieveToken(forKey: "authorizationToken")
    }
    
    var onTokenChangedToNil: (() -> Void)?
    
    var userLoggedIn: Bool {
        token == nil ? false: true
    }
    
    func checkIfTokenChangedToNil() {
        if !userLoggedIn {
            onTokenChangedToNil?()
        }
    }
}
