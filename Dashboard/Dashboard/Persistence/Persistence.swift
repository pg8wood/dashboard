//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

protocol Database {
    func getStoredServices() -> [ServiceModel]
    func save(newService: ServiceModel)
}

class PersistenceClient: Database {
    func getStoredServices() -> [ServiceModel] {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let fetchedServices = try managedContext.fetch(serviceFetchRequest) as! [ServiceModel]
            return fetchedServices
        } catch {
            fatalError("Failed to fetch service models: \(error)")
        }
    }
    
    func save(newService: ServiceModel) {
        // TODO
    }
}
