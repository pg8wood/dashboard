//
//  WatchData.swift
//  DashboardWatch Extension
//
//  Created by Patrick Gatewood on 10/1/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Combine

class WatchData: ObservableObject {
    @Published var services: [SimpleServiceModel] = []
}
