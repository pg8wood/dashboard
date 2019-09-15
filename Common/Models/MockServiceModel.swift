//
//  MockServiceModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/15/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit

public class MockServiceModel: ServiceModel {

    /// There's probably a better way to mock a CoreData object's properties... but this works for now.
    var mockIndex: Int64 = 0
    override var index: Int64 {
        set { mockIndex = newValue }
        get { return mockIndex }
    }
    
    var mockName: String = "Service name"
    override var name: String {
        set { mockName = newValue }
        get { return mockName }
    }
    
    var mockUrl: String = "https://patrickgatewood.com"
    override var url: String {
        set { mockUrl = newValue }
        get { return mockUrl }
    }
    
    var mockLastOnlineDate: Date = .init(timeIntervalSinceNow: .zero)
    override var lastOnlineDate: Date {
        set { mockLastOnlineDate = newValue }
        get { return mockLastOnlineDate }
    }

    override var image: UIImage {
        set { /* Not supported */ }
        get { UIImage(named: "missing-image")! }
    }

    convenience init(index: Int64 = 0, name: String = "Service name", url: String = "https://patrickgatewood.com", lastOnlineDate: Date = .init(timeIntervalSinceNow: .zero)) {
        self.init()
        self.mockIndex = index
        self.mockName = name
        self.mockUrl = url
        self.lastOnlineDate = lastOnlineDate
    }
}
