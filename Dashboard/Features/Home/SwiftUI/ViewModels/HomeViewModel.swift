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
    
    func loadServices() {
        PersistenceClient.shared.getStoredServices { [weak self ] result in
            guard let self = self else { return }
            
            let services = (try? result.get()) ?? [ServiceModel]()
            let serviceViewModels = services.map { ServiceRowViewModel(model: $0) }
            
            self.services = serviceViewModels
        }
    }
    
    func fetchServerStatuses() {
        for service in services {
            service.fetchStatus()
        }
    }
}
