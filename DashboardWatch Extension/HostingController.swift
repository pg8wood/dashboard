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

// TODO move this
class WatchData: ObservableObject {
    @Published var services = ["Hello world!"]
}

class HostingController: WKHostingController<AnyView> {
    private var watchData = WatchData()
    
    override var body: AnyView {
        return AnyView(ContentView()
            .environmentObject(watchData))
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
        print("Watch session ON WATCH activation completed!")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // TODO: maybe use a publisher to send messages from here to the view??
        
        //      let message = message["message"] as! String
        //      print(message)
        print("message received ON WATCH from iPhone")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.watchData.services.append("we got a message!")
        }
        
        replyHandler(["msg":"message received ON WATCH from iPhone"])
    }
}
