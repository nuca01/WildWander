//
//  UIColor.swift
//  WildWander
//
//  Created by nuca on 08.07.24.
//

import UIKit

extension UIColor {
    static func with(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 100)
    }
}
