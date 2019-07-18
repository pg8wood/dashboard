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
    
    func createService(name: String, url: String, image: UIImage,
                       completion: @escaping (_ result: Result<ServiceModel, Error>) -> Void){
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let numberOfServices = try managedContext.count(for: serviceFetchRequest)
            
            let service = NSEntityDescription.insertNewObject(forEntityName: ServiceModel.entityName, into: PersistenceClient.persistentContainer.viewContext) as! ServiceModel
            
            service.populate(index: Int64(numberOfServices), name: name, url: url, image: image)
            save(image: image, named: name)
            
            completion(.success(service))
        } catch {
            completion(.failure(error))
        }
    }
    
    func edit(service: ServiceModel, name: String, url: String, image: UIImage) {
        service.populate(index: service.index, name: name, url: url, image: image)
    }
    
    /// Swap two services' indices in the database
    func swap(service: ServiceModel, with otherService: ServiceModel) {
        let firstIndex = service.index
        let secondIndex = service.index
        
        service.index = secondIndex
        otherService.index = firstIndex
    }
}
