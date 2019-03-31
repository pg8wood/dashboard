//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

// TOOD: duplicated code
import CoreData
import UIKit

protocol Database {
    func getStoredServices() -> [ServiceModel]
    func save(image: UIImage, named fileName: String)
    func renameFile(from oldFileName: String, to newFileName: String)
}

class PersistenceClient {
    static func fetchImage(named: String) -> UIImage? {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageFilePath = documentsUrl.appendingPathComponent("\(named)")
        
        return UIImage(contentsOfFile: imageFilePath.path)
    }
}

//extension PersistenceClient: Database {
//    func getStoredServices() -> [ServiceModel] {
//        
////        let managedContext = appDelegate.persistentContainer.viewContext
////        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
////
////        do {
////            let fetchedServices = try managedContext.fetch(serviceFetchRequest) as! [ServiceModel]
////            return fetchedServices
////        } catch {
////            fatalError("Failed to fetch service models: \(error)")
////        }
//        return []
//    }
//    
//    /**
//     Saves an image to the Documents directory.
//     
//     - Parameter image: the image to save
//     - Parameter fileName: the name of the file to save the image in. Don't pass the extension.
//     */
//    func save(image: UIImage, named fileName: String) {
//        let fileManager = FileManager.default
//        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let imageFilePath = documentsUrl.appendingPathComponent("\(fileName)")
//        
//        do {
//            let files = try fileManager.contentsOfDirectory(atPath: documentsUrl.path)
//            
//            if files.contains(imageFilePath.path) {
//                try fileManager.removeItem(atPath: imageFilePath.path)
//            }
//            
//            if let imagePngData = image.pngData() {
//                try imagePngData.write(to: imageFilePath, options: .atomic)
//            }
//        } catch {
//            print("Failed to save image: \(error)")
//        }
//    }
//    
//    func renameFile(from oldFileName: String, to newFileName: String) {
//        let fileManager = FileManager.default
//        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let oldImageFilePath = documentsUrl.appendingPathComponent("\(oldFileName)")
//        let newImageFilePath = documentsUrl.appendingPathComponent("\(newFileName)")
//        
//        do {
//            try fileManager.moveItem(at: oldImageFilePath, to: newImageFilePath)
//        } catch {
//            print("Failed to rename image. Saving new instead")
//        }
//    }
//}
