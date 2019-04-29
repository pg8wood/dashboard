import Vapor
import FluentSQLite

final class Service: Codable {
    var id: Int?
    var name: String
    var url: String
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

extension Service: SQLiteModel { }
extension Service: Migration { }
extension Service: Content { }
extension Service: Parameter { }
