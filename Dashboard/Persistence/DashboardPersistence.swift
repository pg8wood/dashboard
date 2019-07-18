//
//  DashboardPersistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 7/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

// TODO unit test these protocols
protocol ServiceDatabase: Database {
    func createService(name: String, url: String, image: UIImage) -> ServiceModel
    func edit(service: ServiceModel, name: String, url: String, image: UIImage)
}

extension PersistenceClient: ServiceDatabase {
    func createService(name: String, url: String, image: UIImage) -> ServiceModel {
        let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: PersistenceClient.persistentContainer.viewContext) as! ServiceModel
        
        service.populate(name: name, url: url, image: image)
        return service
    }
    
    func edit(service: ServiceModel, name: String, url: String, image: UIImage) {
        service.populate(name: name, url: url, image: image)
    }
}
