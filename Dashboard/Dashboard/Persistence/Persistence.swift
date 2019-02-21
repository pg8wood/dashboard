//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

protocol Database {
    func getStoredServices() -> [ServiceModel]
    func save(newService: ServiceModel)
}

class PersistenceClient: Database {
    func getStoredServices() -> [ServiceModel] {
        return []
    }
    
    func save(newService: ServiceModel) {
        // TODO
    }
}
