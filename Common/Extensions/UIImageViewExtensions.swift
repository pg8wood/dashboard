//
//  UIImageViewExtensions.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 10/1/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

extension UIImage {
    func toBase64String() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
