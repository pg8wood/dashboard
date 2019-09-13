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

class ServiceRowViewModel: ObservableObject, Identifiable {
    private var model: ServiceModel
    
    var name: String {
        model.name
    }
    
    var url: String {
        model.url
    }
    
    var image: UIImage {
        model.image
    }
    
    var status: Status {
        return model.wasOnlineRecently ? .online : .offline // TODO might move status into the model if possible
    }
    
    var id: String {
        return url
    }
    
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
    
    init(networkService: NetworkFetchable, model: ServiceModel) {
        self.networkService = networkService
        self.model = model
    }
    
//    convenience init(name: String = "", url: String = "", image: UIImage = UIImage(named: "missing-image")!, status: Status = .unknown) {
//        let model = ServiceModel()
//        model.populate(index: 0, name: name, url: url, image: image, lastOnlineDate: .init(timeIntervalSinceNow: .zero))
//        
//        self.init(networkService: NetworkService(), model: model)
//    }
    
    func fetchStatus() {
        networkService.fetchServerStatus(for: self.url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .failure:
                        // TODO: do we need to update this here?
//                    self.model.lastOnlineDate = .init
                        // TODO if not, just get rid of this completion block 
                        break
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] statusCode in
                    guard let self = self else { return }
                    
                    guard statusCode == 200 else {
                        return
                    }
                    
                    self.model.lastOnlineDate = .init(timeIntervalSinceNow: .zero)
                })
            .store(in: &disposables)
    }
}
