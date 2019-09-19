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
    func createService(name: String, url: String, image: UIImage,
                       completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void)
    func edit(service: ServiceModel, name: String, url: String, image: UIImage)
    func swap(service: ServiceModel, with otherService: ServiceModel)
}

extension PersistenceClient: ServiceDatabase {
    
    static let shared = PersistenceClient()
    
    static func allServicesFetchRequest() -> NSFetchRequest<ServiceModel> {
        let request = ServiceModel.fetchRequest() as! NSFetchRequest<ServiceModel>
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ServiceModel.index, ascending: true)]
        
        return request
    }
    
    func createService(name: String, url: String, image: UIImage,
                       completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void){
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let numberOfServices = try managedContext.count(for: serviceFetchRequest)
            
            let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: PersistenceClient.persistentContainer.viewContext) as! ServiceModel
            
            service.populate(index: Int64(numberOfServices), name: name, url: url, lastOnlineDate: .distantPast)
            save(image: image, named: name)
            
            completion(.success(service))
            saveContext()
        } catch {
            completion(.failure(error))
        }
    }
    
    func edit(service: ServiceModel, name: String, url: String, image: UIImage) {
        service.populate(index: service.index, name: name, url: url, lastOnlineDate: service.lastOnlineDate)
        saveContext()
    }
    
    /// Swap two services' indices in the database
    func swap(service: ServiceModel, with otherService: ServiceModel) {
        service.index += otherService.index
        otherService.index = service.index - otherService.index
        service.index -= otherService.index
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    // Saves changes in the application's managed object context before the application terminates.
    func saveContext () {
        let context = PersistenceClient.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
