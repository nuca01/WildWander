//
//  InformationEntryViewModel.swift
//  WildWander
//
//  Created by nuca on 20.07.24.
//

import Foundation

class InformationEntryViewModel {
    private let genders = ["Male", "Female"]
    var genderCount: Int {
        genders.count
    }
    
    func genderFor(index: Int) -> String {
        genders[index]
    }
    
}
