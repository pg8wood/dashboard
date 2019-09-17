//
//  ServiceList.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/17/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine

class ServiceList: ObservableObject {
    @Published var services: [ServiceModel]
    
    init(services: [ServiceModel]) {
        self.services = services
    }
}
