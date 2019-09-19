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
            let homeView = HomeView().environment(\.managedObjectContext, moc)

            window.rootViewController = UIHostingController(rootView: homeView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
