//
//  UserModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 5/24/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

struct UserModel: Codable {
    //    var id: Int?
    var pushToken: Data
    
    public init(pushToken: Data) {
        self.pushToken = pushToken
    }
}
