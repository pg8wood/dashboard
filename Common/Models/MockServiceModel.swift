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

    convenience init(name: String = "Service name", url: String = "https://patrickgatewood.com", lastOnlineDate: Date = .init(timeIntervalSinceNow: .zero)) {
        self.init()
        self.mockName = name
        self.mockUrl = url
        self.lastOnlineDate = lastOnlineDate
    }
}
