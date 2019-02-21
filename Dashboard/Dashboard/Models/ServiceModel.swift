//
//  ServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

public class ServiceModel {
    
    public var name: String
    public var url: String
    public var image: UIImage
    
    init(name: String, url: String, image: UIImage) {
        self.name = name
        self.url = url
        self.image = image
    }
}
