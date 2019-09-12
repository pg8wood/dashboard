//
//  Service.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum Status {
    case online
    case offline
    case unknown
}

class ServiceRowViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var url: String = ""
    @Published var image: UIImage = UIImage(named: "missing-image")!
    @Published var status: Status = .unknown
    
    var statusImage: UIImage {
        switch status {
        case .online:
            return UIImage(named: "check")!
        case .offline, .unknown:
            return UIImage(named: "server-error")!
        }
    }
    
    private let networkService: NetworkFetchable!
    private var disposables = Set<AnyCancellable>()
    
    init(networkService: NetworkFetchable) {
        self.networkService = networkService
    }
    
    func fetchStatus() {
        networkService.fetchServerStatus(for: self.url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] value in
                    guard let self = self else { return }
                    
                    switch value {
                    case .failure:
                        self.status = .offline // TODO error status maybe?
                        break
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] statusCode in
                    guard let self = self else { return }
                    
                    guard statusCode == 200 else {
                        self.status = .offline // TODO error status maybe?
                        return
                    }
                    
                    self.status = .online
                })
            .store(in: &disposables)
    }
}
