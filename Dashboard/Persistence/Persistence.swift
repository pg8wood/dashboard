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
    func save(image: UIImage, named fileName: String) -> String
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
    
    /**
     Saves an image to the Documents directory.
     
     - Parameter image: the image to save
     - Parameter fileName: the name of the file to save the image in. Don't pass the extension.
     
     -Returns: The file path to the saved image.
     */
    func save(image: UIImage, named fileName: String) -> String {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFilePath = documentsUrl.appendingPathComponent("\(String(fileName))")
        
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
        
        return imageFilePath.path
    }
}
