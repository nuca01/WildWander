//
//  TrailAddable.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import Foundation

protocol TrailAddable: NavigatePageViewController {
    func addTrail(_: Trail) -> Void
}
