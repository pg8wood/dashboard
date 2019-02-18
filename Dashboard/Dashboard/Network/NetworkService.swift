//
//  NetworkService.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
import FavIcon
import PinkyPromise

public enum NetworkError: Error {
    case InvalidUrl
    case NoResponse
}

public class NetworkService {
    
    public static func fetchServerStatus(url: String) -> Promise<Int> {
        guard let url = URL(string: url) else {
            return Promise(error: NetworkError.InvalidUrl)
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
                    fulfill(.failure(NetworkError.NoResponse))
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
                try FavIcon.downloadPreferred(url) { result in
                    // Hmmm... mixing 2 promimse/result libraries here?
                    // TODO: Investigate. This looks kinda code smelly
                    if case let .success(image) = result {
                        fulfill(.success(image))
                        return
                    } else if case let .failure(error) = result {
                        print("failed to download preferred favicon for \(url): \(error)")
                        fulfill(.failure(error))
                    }
                }
            } catch let error {
                print("failed to download preferred favicon for \(url): \(error)")
                fulfill(.failure(error))
            }
        }
    }
}
