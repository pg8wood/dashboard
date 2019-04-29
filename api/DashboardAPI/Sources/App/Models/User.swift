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
    var services: [Service]
    
    init(id: Int, services: [Service]) {
        self.id = id
        self.services = services
    }
}

extension User: SQLiteModel { }
extension User: Migration { }
extension User: Content { }
extension User: Parameter { }
