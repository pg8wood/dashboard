//
//  UIColorExtensions.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 7/16/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let textColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .lightText
        case .light, .unspecified:
            return .darkText
        @unknown default: // Could there be other interface styles in the future?
            return .darkText
        }
    }
    
    static let loadingIndicatorColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .white
        case .light, .unspecified:
            return .gray
        @unknown default:
            return .gray
        }
    }
    
    static let widgetLoadingIndicatorColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .white
        case .light, .unspecified:
            return .black
        @unknown default:
            return .black
        }
    }
}
