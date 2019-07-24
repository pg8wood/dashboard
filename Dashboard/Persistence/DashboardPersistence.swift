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
extension Database {
    func createService(name: String, url: String, image: UIImage,
                       completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void) {
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let numberOfServices = try managedContext.count(for: serviceFetchRequest)
            
            let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: managedContext) as! ServiceModel
            
            service.populate(index: Int64(numberOfServices), name: name, url: url, image: image, lastOnlineDate: .distantPast)
            save(image: image, named: name)
            
            completion(.success(service))
        } catch {
            completion(.failure(error))
        }
    }
    
    func edit(service: ServiceModel, name: String, url: String, image: UIImage) {
        service.populate(index: service.index, name: name, url: url, image: image, lastOnlineDate: service.lastOnlineDate)
    }
    
    /// Swap two services' indices in the database
    func swap(itemAt sourceIndexPath: IndexPath, with destinationIndexPath: IndexPath) {
        let sourceService = fetchedResultsController.object(at: sourceIndexPath) as! ServiceModel
        let destinationService = fetchedResultsController.object(at: destinationIndexPath) as! ServiceModel

        let sourceIndex = sourceService.index

        sourceService.index = destinationService.index
        destinationService.index = sourceIndex
    }
}
