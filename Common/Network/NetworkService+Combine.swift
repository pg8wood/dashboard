//
//  NetworkService+Combine.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine
import FavIcon

enum NetworkError: Error {
    case invalidUrl
    case noResponse
    case error(description: String)
}

protocol NetworkFetchable {
    func fetchServerStatus(for url: String) -> AnyPublisher<Int, NetworkError>
//    func fetchFavicon(for url: String) -> AnyPublisher<UIImage, NetworkError>
}

class NetworkService {
    private let session: URLSession!
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkService: NetworkFetchable {
    func fetchServerStatus(for url: String) -> AnyPublisher<Int, NetworkError> {
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
    
//    func fetchFavicon(for url: String) -> AnyPublisher<UIImage, NetworkError> {
//        // TODO
//    }
}
