//
//  ServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit
import Combine

protocol Service {
    var index: Int64 { get set }
    var name: String { get set }
    var url: String { get set }
    var lastOnlineDate: Date { get set }
    var wasOnlineRecently: Bool { get }
}

@objc(ServiceModel)
public class ServiceModel: NSManagedObject, Service, Identifiable {
    static var entityName: String {
        return String(describing: self)
    }
    
    @NSManaged var index: Int64
    @NSManaged var name: String
    @NSManaged var url: String
    @NSManaged var lastOnlineDate: Date
    
    /// Determine if the service was online in the last 5 minutes
    var wasOnlineRecently: Bool {
        return Date().timeIntervalSince(lastOnlineDate) <= 60 * 5
    }

    var image: UIImage {
        get {
            return PersistenceClient.fetchImage(named: imageName) ?? UIImage(named: "missing-image")!
        }
    }
    
    var imageName: String {
        return "\(index)-\(name)" // arbitrary unique image name
    }
    
    func populate(index: Int64, name: String, url: String, lastOnlineDate: Date) {
        self.index = index
        self.name = name
        self.url = url
        self.lastOnlineDate = lastOnlineDate
    }
    
    // MARK: - Combine
    var didChange = PassthroughSubject<Void, Never>()
    
    public override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        didChange.send()
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case index
        case name
        case url
        case lastOnlineDate
    }
    
}
extension ServiceModel: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(lastOnlineDate, forKey: .lastOnlineDate)
    }
}

// Definitely a smell to duplicate the data here. However, turns out serializing Core Data models and decoding them on the watch is a bad idea too. TODO need to figure out best course action.
struct SimpleServiceModel: Decodable, Service {
    var index: Int64
    var name: String
    var url: String
    var lastOnlineDate: Date
    
    /// Determine if the service was online in the last 5 minutes
    var wasOnlineRecently: Bool {
        return Date().timeIntervalSince(lastOnlineDate) <= 60 * 5
    }
}
