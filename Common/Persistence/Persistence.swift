//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

protocol Database {
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> { get }
    
    func save(image: UIImage, named fileName: String)
    func renameFile(from oldFileName: String, to newFileName: String)
    func updateLastOnlineDate(for service: ServiceModel, lastOnline: Date)
}

class PersistenceClient {
    
    static let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.willowtreeapps.patrick.gatewood.dashboard")!
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Services")
        let storeUrl = documentsUrl.appendingPathComponent("services.sqlite")
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var fetchController: NSFetchedResultsController<NSFetchRequestResult>!
    
    init(delegate: NSFetchedResultsControllerDelegate) {
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let sortDescriptor = NSSortDescriptor(keyPath: \ServiceModel.index, ascending: true)
        
        serviceFetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchController = NSFetchedResultsController(fetchRequest: serviceFetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegate
        
        do {
            try fetchController.performFetch()
        } catch {
            // TODO have delegate show error
            fatalError("Failed to fetch service models: \(error)")
        }
    }
    
    static func fetchImage(named: String) -> UIImage? {
        let imageFilePath = documentsUrl.appendingPathComponent("\(named)")
        return UIImage(contentsOfFile: imageFilePath.path)
    }
}

extension PersistenceClient: Database {
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        return fetchController
    }
    
    /**
     Saves an image to the shared App Group bundle.
     
     - Parameter image: the image to save
     - Parameter fileName: the name of the file to save the image in. Don't pass the extension.
     */
    func save(image: UIImage, named fileName: String) {
        let imageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(fileName)")
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: PersistenceClient.documentsUrl.path)
            
            if files.contains(imageFilePath.path) {
                try FileManager.default.removeItem(atPath: imageFilePath.path)
            }
            
            if let imagePngData = image.pngData() {
                try imagePngData.write(to: imageFilePath, options: .atomic)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func renameFile(from oldFileName: String, to newFileName: String) {
        let oldImageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(oldFileName)")
        let newImageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(newFileName)")
        
        do {
            try FileManager.default.moveItem(at: oldImageFilePath, to: newImageFilePath)
        } catch {
            print("Failed to rename image. Saving new instead")
        }
    }
    
    func updateLastOnlineDate(for service: ServiceModel, lastOnline: Date) {
        service.lastOnlineDate = lastOnline
    }
}
