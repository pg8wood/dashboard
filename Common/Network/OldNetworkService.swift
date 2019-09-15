//
//  NetworkService.swift
//  Dashboard
//
//  The old network service used by components written in UIKit. Currently exists for a
//  branch-by-abstraction conversion to a network client written in Combine. May be kept
//  around as a demonstration for what converting a UIKit app to SwiftUI can look like.
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import FavIcon
import PinkyPromise

@available(*, deprecated)
public enum OldNetworkError: Error {
    case invalidUrl
    case noResponse
    case error(description: String)
}

@available(*, deprecated)
public class OldNetworkService {
    
    public static func fetchServerStatus(url: String) -> Promise<Int> {
        guard let url = URL(string: url) else {
            return Promise(error: OldNetworkError.invalidUrl)
        }
     
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        return Promise { fulfill in
            let task = URLSession.shared.dataTask(with: request) { (_ data, response, error) in
                if let error = error {
                    fulfill(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    fulfill(.failure(OldNetworkError.noResponse))
                    return
                }
                
                fulfill(.success(response.statusCode))
            }
            
            task.resume()
        }
    }
    
    public static func fetchFavicon(for url: String) -> Promise<UIImage> {
        return Promise { fulfill in
            do {
                try FavIcon.downloadPreferred(url, width: 500, height: 500) { result in
                    if case let .success(image) = result {
                        fulfill(.success(image))
                        return
                    } else if case let .failure(error) = result {
                        fulfill(.failure(error))
                    }
                }
            } catch let error {
                fulfill(.failure(error))
            }
        }
    }
}
