//
//  HostingController.swift
//  DashboardWatch Extension
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    private var watchData = WatchData()
    
    override var body: AnyView {
        let network = NetworkService(database: nil)
        
        return AnyView(ServiceListView()
            .environmentObject(watchData)
            .environmentObject(network))
    }
    
    var session: WCSession!
    
    override func willActivate() {
        super.willActivate()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
            print("watch connectivity activated ON WATCH!")
        }
    }
}

extension HostingController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch session activation completed!")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("got message from iphone")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let decoder = JSONDecoder()
            
            do {
                let services = try message.values.map { try decoder.decode(SimpleServiceModel.self, from: $0 as! Data) }
                self.watchData.services = services
            } catch {
                print("error decoding service: \(error)")
            }
        }
        
        replyHandler(["msg":"message received from iPhone"])
    }
}
