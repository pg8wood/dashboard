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
    
    @NSManaged var index: Int64
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var lastOnlineDate: Date
    
    /// Determine if the service was online in the last 5 minutes
    var wasOnlineRecently: Bool {
        return Date().timeIntervalSince(lastOnlineDate) <= 60 * 5
    }

    var inMemoryImage: UIImage?
    var image: UIImage {
        get {
            return inMemoryImage ?? PersistenceClient.fetchImage(named: name) ?? UIImage(named: "missing-image")!
        } set {
            inMemoryImage = newValue
        }
    }
    
    func populate(index: Int64, name: String, url: String, image: UIImage, lastOnlineDate: Date) {
        self.index = index
        self.name = name
        self.url = url
        self.image = image
        self.lastOnlineDate = lastOnlineDate
    }
}
