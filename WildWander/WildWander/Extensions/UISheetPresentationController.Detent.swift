//
//  UISheetPresentationController.Detent.swift
//  WildWander
//
//  Created by nuca on 14.07.24.
//

import UIKit

extension UISheetPresentationController.Detent {
    class func small() -> UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: .small) { context in
            return 60
        }
    }

    class func myLarge() -> UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: .myLarge) { context in
            return context.maximumDetentValue - 0.1
        }
    }
    
    class func interactiveMedium() -> UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: .interactiveMedium) { context in
            return 290
        }
    }
    
    class func smallThanMedium() -> UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: .smallThanMedium) { context in
            return 170
        }
    }
}
