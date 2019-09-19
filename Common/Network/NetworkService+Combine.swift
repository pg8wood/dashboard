//
//  NetworkService+Combine.swift
//  Dashboard
//
//  Network client written in Combine.
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine
import FavIcon
import SwiftUI

enum NetworkError: Error {
    case invalidUrl
    case noResponse
    case error(description: String)
}

protocol NetworkFetchable {
    func fetchServerStatusCode(for url: String) -> AnyPublisher<Int, NetworkError>
    func updateServerStatus(for service: ServiceModel)
}

class NetworkService: ObservableObject {
    let database: PersistenceClient
    
    private let session: URLSession!
    
    private var disposables = Set<AnyCancellable>()
    
    init(session: URLSession = .shared, database: PersistenceClient) {
        self.session = session
        self.database = database
    }
}

extension NetworkService: NetworkFetchable {
    func fetchServerStatusCode(for url: String) -> AnyPublisher<Int, NetworkError> {
        guard let url = URL(string: url) else {
            return Fail(error: NetworkError.invalidUrl).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.noResponse
                }

            return response.statusCode
        }
        .catch { error in
            return Fail(error: NetworkError.error(description: error.localizedDescription)).eraseToAnyPublisher()
        }
        .mapError { error in
            NetworkError.error(description: error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
    
    func updateServerStatus(for service: ServiceModel) {
        _ = fetchServerStatusCode(for: service.url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.database.updateLastOnlineDate(for: service, lastOnline: .distantPast)
                }
            }, receiveValue: { responseCode in
                print("response code: \(responseCode)")
                // TODO potential improvement: Show icons/descriptions for server-related errors outside of the success range
                guard 200..<300 ~= responseCode else {
                    self.database.updateLastOnlineDate(for: service, lastOnline: .distantPast)
                    return
                }
                
                self.database.updateLastOnlineDate(for: service, lastOnline: Date())
            })
            .store(in: &disposables) // whoops, if we don't retain this cancellable object the network data task will be cancelled
    }
}
