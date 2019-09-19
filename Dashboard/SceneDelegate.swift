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
            let moc = PersistenceClient.persistentContainer.viewContext
            let database = PersistenceClient()
            let network = NetworkService(database: database)
            
            let homeView = HomeView()
                .environment(\.managedObjectContext, moc)
                .environmentObject(database)
                .environmentObject(network)

            self.window = window
            
            window.rootViewController = UIHostingController(rootView: homeView)
            window.makeKeyAndVisible()
        }
    }
}
