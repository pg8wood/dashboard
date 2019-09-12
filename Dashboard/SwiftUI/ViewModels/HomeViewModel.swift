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
    
    private let networkService: NetworkFetchable!
    private var disposables = Set<AnyCancellable>()

    init(networkService: NetworkFetchable) {
        self.networkService = networkService
    }
    
    func fetchStatuses(forServices services: [ServiceRowViewModel]) { // TODO should that be the model type instead of viewmodel type?
        for service in services {
            service.fetchStatus()
        }
    }
}
