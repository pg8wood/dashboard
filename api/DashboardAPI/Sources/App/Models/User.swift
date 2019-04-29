//
//  UserModel.swift
//  App
//
//  Created by Patrick Gatewood on 4/29/19.
//

import Vapor
import FluentSQLite

final class User {
    var id: Int?
    var pushToken: String
    var services: [Service]?
    
    init(pushToken: String) {
        self.pushToken = pushToken
    }
}

extension User: SQLiteModel { }
extension User: Migration { }
extension User: Content { }
extension User: Parameter { }
