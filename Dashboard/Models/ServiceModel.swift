//
//  ServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData

@objc(ServiceModel)
public class ServiceModel: NSManagedObject {
    static var entityName: String {
        return String(describing: self)
    }
    
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var imagePath: String
    
    func populate(name: String, url: String, imageUrl: String) {
        self.name = name
        self.url = url
        self.imagePath = imageUrl
    }
}
