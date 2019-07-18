//
//  UIViewControllerExtensions.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 7/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

extension UIViewController {
    func show(error: Error, withTitle title: String = "Error") {
        let alertViewController = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .actionSheet)
        present(alertViewController, animated: true)
    }
}
