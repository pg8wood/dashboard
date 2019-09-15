//
//  MockNetworkService.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/12/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine

private var publisher = PassthroughSubject<Int, NetworkError>()

class MockNetworkService: NetworkFetchable {
    func fetchServerStatus(for url: String) -> AnyPublisher<Int, NetworkError> {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 500) {
            publisher.send(200)
        }
        return publisher.eraseToAnyPublisher()
    }
}
