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
    
    var image: UIImage? {
        return PersistenceClient.fetchImage(named: name) ?? UIImage(named: "missing-image")
    }
    
    func populate(name: String, url: String) {
        self.name = name
        self.url = url
    }
}
