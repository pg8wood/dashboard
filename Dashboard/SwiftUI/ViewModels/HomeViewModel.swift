//
//  HomeViewModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/12/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var services: [ServiceRowViewModel] = []
    
    let networkService: NetworkFetchable!
    private var disposables = Set<AnyCancellable>()

    init(networkService: NetworkFetchable) {
        self.networkService = networkService
    }
    
    convenience init(services: [ServiceRowViewModel]) {
        self.init(networkService: NetworkService())
        self.services = services
        fetchServerStatuses()
    }
    
    func fetchServerStatuses() {
        for service in services {
            service.fetchStatus()
        }
    }
}
