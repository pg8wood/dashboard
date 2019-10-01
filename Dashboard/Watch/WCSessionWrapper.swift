//
//  WCSessionWrapper.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/30/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import WatchConnectivity

@propertyWrapper
struct WatchSession {
    private var delegate: WCSessionDelegate?
    
    var wrappedValue: WCSession?
    
    init(delegate: WCSessionDelegate?) {
        self.delegate = delegate
        self.wrappedValue = initializeWCSession()
    }
    
    private func initializeWCSession() -> WCSession? {
        guard WCSession.isSupported() else { return nil }

        let session = WCSession.default
        session.delegate = delegate
        session.activate()
        return session
    }
}
