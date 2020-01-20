//
//  URLError+ShortCodes.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 1/20/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import Foundation

extension URLError {
    var shortLocalizedDescription: String {
        switch code {
        case .badURL:
            return "Invalid URL"
        case .cannotFindHost, .cannotConnectToHost:
            return "No response"
        case .badServerResponse:
            return "Invalid response"
        default:
            return "Unknown error"
        }
    }
}
