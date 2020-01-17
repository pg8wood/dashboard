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
import SwiftUI

protocol NetworkFetchable {
    func fetchServerStatusCode(for url: String) -> AnyPublisher<Int, URLError>
    func updateServerStatus(for service: ServiceModel) -> PassthroughSubject<Bool, Never>
}

class NetworkService: ObservableObject {
    let database: PersistenceClient?
    
    private let session: URLSession!
    
    private var disposables = Set<AnyCancellable>()
    
    init(session: URLSession = .shared, database: PersistenceClient?) {
        self.session = session
        self.database = database
    }
}

extension NetworkService: NetworkFetchable {
    
    /// Gets the response code from a HEAD request. This is a tad slower than pinging the server, however since many servers block
    /// ICMP requests, this should be more reliable.
    func fetchServerStatusCode(for url: String) -> AnyPublisher<Int, URLError> {
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        return session.dataTaskPublisher(for: url)
        .tryMap { data, response in
            guard let response = response as? HTTPURLResponse else {
                throw URLError(.timedOut) // TODO: is this the right way to handle this case?
            }
            
            return response.statusCode
        }
        .mapError { error in
            error as? URLError ?? URLError(.unknown)
        }
        .eraseToAnyPublisher()
    }
    
    func updateServerStatus(for service: ServiceModel) -> PassthroughSubject<Bool, Never> {
        let networkActivityPublisher = PassthroughSubject<Bool, Never>()
        
        _ = fetchServerStatusCode(for: service.url)
            .handleEvents(receiveSubscription: { _ in
                networkActivityPublisher.send(true)
            }, receiveCompletion: { _ in
                networkActivityPublisher.send(false)
            }, receiveCancel: {
                networkActivityPublisher.send(false)
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.database?.updateLastOnlineDate(for: service, lastOnline: .distantPast)
                }
            }, receiveValue: { responseCode in
                // TODO potential improvement: Show icons/descriptions for server-related errors outside of the success range
                guard 200..<300 ~= responseCode else {
                    self.database?.updateLastOnlineDate(for: service, lastOnline: .distantPast)
                    return
                }
                
                self.database?.updateLastOnlineDate(for: service, lastOnline: Date())
            })
            .store(in: &disposables) // whoops, if we don't retain this cancellable object the network data task will be cancelled
        
        return networkActivityPublisher
    }
}
