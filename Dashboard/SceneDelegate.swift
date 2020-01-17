//
//  SceneDelegate.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let moc = PersistenceClient.persistentContainer.viewContext // todo do we still need this?
            let database = PersistenceClient()
            let network = NetworkService(database: database)
            let settings = Settings()
            
            let dashboardTabView = DashboardTabView()
                .environment(\.managedObjectContext, moc)
                .environmentObject(database)
                .environmentObject(network)
            .environmentObject(settings)
                .environmentObject(WatchHandler(moc: moc))

            self.window = window
            
            window.rootViewController = UIHostingController(rootView: dashboardTabView)
            window.makeKeyAndVisible()
        }
    }
}
