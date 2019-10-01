//
//  WatchSessionDelegate.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/30/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import WatchConnectivity
import CoreData

class WatchHandler: ObservableObject {
    @WatchSession(delegate: WatchSessionDelegate()) var watchSession: WCSession?
    
    private let moc: NSManagedObjectContext
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
        observeCoreDataChanges()
    }
    
    private func observeCoreDataChanges() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: moc)
    }
    
    func replyHandler(reply: [String : Any]) {
        print("the watch received the phone's message")
    }
    
    // Note: It's probaby better to exclusively look for inserts, updates, and deletes from within this notification, but this will suffice for innovation day.
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        PersistenceClient.shared.getStoredServices { [weak self] result in
            guard let self = self else { return }
            
            do {
                let services = try result.get()
                let encoder = JSONEncoder()
                let serviceDict = try Dictionary(uniqueKeysWithValues: services.map { ($0.name, try encoder.encode($0)) })
                
                self.watchSession?.sendMessage(serviceDict, replyHandler: self.replyHandler, errorHandler: nil)
            } catch {
                print("Error getting services")
                // TODO handle error
            }
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watch session activation completed")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("watch session inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("watch session deactivated")
    }
}
