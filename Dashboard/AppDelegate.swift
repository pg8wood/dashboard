//
//  AppDelegate.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/18/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      // Called when a new scene session is being created.
      // Use this method to select a configuration to create the new scene with.
      return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - UIKit <--> SwiftUI toggle
    
    enum Implementation {
        case UIKit
        case SwiftUI
    }
    
    func switchHomeView(to implementaion: Implementation) {
        switch(implementaion) {
        case .UIKit, .SwiftUI:
            presentUIKitImplementation()
        }
    }
    
    private func presentSwiftUIImplementation() {
        let window = UIApplication.shared.windows.first!
              
      let moc = PersistenceClient.persistentContainer.viewContext
      let database = PersistenceClient()
      let network = NetworkService(database: database)
      
      let homeView = HomeView()
          .environment(\.managedObjectContext, moc)
          .environmentObject(database)
          .environmentObject(network)
      
      window.rootViewController = UIHostingController(rootView: homeView)
      window.makeKeyAndVisible()
    }
    
    func presentUIKitImplementation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        let window = UIApplication.shared.windows.first!
        window.rootViewController = homeViewController
        window.makeKeyAndVisible()
    }
}
