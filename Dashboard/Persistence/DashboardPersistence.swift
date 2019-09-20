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
    func createService(name: String, url: String, image: UIImage, completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void)
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
    
    func createService(name: String, url: String, image: UIImage, completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void) {
        getStoredServices { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "nil self while trying to persist new ServiceModel"])))
                    return
                }
                
                do {
                    let services = try result.get()
                    
                    // Find the current largest index and increment it. This is not the most efficient way to get a unique ID for a ServiceModel, but it's good enough for innovation day
                    let largestIndex = services.map { $0.index }.max()! + 1
                    
                    let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: PersistenceClient.persistentContainer.viewContext) as! ServiceModel
                    service.populate(index: largestIndex, name: name, url: url, lastOnlineDate: .distantPast)
                    self.save(image: image, named: service.imageName)
                    
                    completion(.success(service))
                    self.saveContext()
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func edit(service: ServiceModel, name: String, url: String, image: UIImage) {
        let oldImageName = service.imageName
        service.populate(index: service.index, name: name, url: url, lastOnlineDate: service.lastOnlineDate)
        renameFile(from: oldImageName, to: service.imageName)
        saveContext()
    }
    
    /// Swap two services' indices in the database
    func swap(service: ServiceModel, with otherService: ServiceModel) {
        let sourceIndex = service.index
        let sourceImageName = service.imageName
        let destinationIndex = otherService.index
        let destinationImageName = otherService.imageName
        
        service.index = destinationIndex
        otherService.index = sourceIndex

        renameFile(from: sourceImageName, to: service.imageName)
        renameFile(from: destinationImageName, to: otherService.imageName)
        
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
