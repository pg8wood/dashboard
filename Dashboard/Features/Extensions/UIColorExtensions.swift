//
//  UIColorExtensions.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 7/16/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let serviceCellBackground = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .tertiarySystemFill
        case .light, .unspecified:
            return .tertiarySystemFill
        @unknown default: // Could there be other interface styles in the future?
            return .tertiarySystemFill
        }
    }
}
