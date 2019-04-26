//
//  ServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

@objc(ServiceModel)
public class ServiceModel: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
    
    @NSManaged var name: String
    @NSManaged var url: String
    
    var inMemoryImage: UIImage?
    var image: UIImage {
        get {
            return inMemoryImage ?? PersistenceClient.fetchImage(named: name) ?? UIImage(named: "missing-image")!
        } set {
            inMemoryImage = newValue
        }
    }
    
    func populate(name: String, url: String, image: UIImage) {
        self.name = name
        self.url = url
        self.image = image
    }
}
