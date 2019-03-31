//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

//let appDelegate = UIApplication.shared.delegate as! AppDelegate

protocol Database {
    func getStoredServices() -> [ServiceModel]
    func save(image: UIImage, named fileName: String)
    func renameFile(from oldFileName: String, to newFileName: String)
}

class PersistenceClient {
    static func fetchImage(named: String) -> UIImage? {
        let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.patrickgatewood.dashboard")!
        let imageFilePath = documentsUrl.appendingPathComponent("\(named)")
        
        return UIImage(contentsOfFile: imageFilePath.path)
    }
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Services")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

extension PersistenceClient: Database {
    func getStoredServices() -> [ServiceModel] {
        
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let fetchedServices = try managedContext.fetch(serviceFetchRequest) as! [ServiceModel]
            return fetchedServices
        } catch {
            fatalError("Failed to fetch service models: \(error)")
        }
    }
    
    /**
     Saves an image to the shared App Group bundle.
     
     - Parameter image: the image to save
     - Parameter fileName: the name of the file to save the image in. Don't pass the extension.
     */
    func save(image: UIImage, named fileName: String) {
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.patrickgatewood.dashboard")!
        let imageFilePath = documentsUrl.appendingPathComponent("\(fileName)")
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsUrl.path)
            
            if files.contains(imageFilePath.path) {
                try fileManager.removeItem(atPath: imageFilePath.path)
            }
            
            if let imagePngData = image.pngData() {
                try imagePngData.write(to: imageFilePath, options: .atomic)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func renameFile(from oldFileName: String, to newFileName: String) {
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.patrickgatewood.dashboard")!
        let oldImageFilePath = documentsUrl.appendingPathComponent("\(oldFileName)")
        let newImageFilePath = documentsUrl.appendingPathComponent("\(newFileName)")
        
        do {
            try fileManager.moveItem(at: oldImageFilePath, to: newImageFilePath)
        } catch {
            print("Failed to rename image. Saving new instead")
        }
    }
}
