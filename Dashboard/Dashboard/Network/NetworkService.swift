//
//  NetworkService.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation
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
                    print("bad url")
                    fulfill(.failure(error))
                    return
                }
                
                // TODO: is this possible?
                guard let response = response as? HTTPURLResponse else {
                    print("no response")
                    fulfill(.failure(NetworkError.NoResponse))
                    return
                }
                
                print("up")
                fulfill(.success(response.statusCode))
            }
            
            task.resume()
        }
    }
}
