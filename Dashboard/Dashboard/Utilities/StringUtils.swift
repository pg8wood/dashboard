//
//  StringUtils.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation

public class StringUtils {
    
    public static func convertString(toHttpsUrl url: String) -> String {
        if url.starts(with: "https://") {
            return url
        }
        
        let protocolString = "https://"
        var httpsUrl: String
        
        if url.starts(with: "http://") {
            // Swift 4 strings... wow
            let index = url.index(after: url.index(url.startIndex, offsetBy: protocolString.count))
            httpsUrl = "https://\(url[index...])"
        } else {
            httpsUrl = "https://\(url)"
        }
        
        return httpsUrl
    }
}
