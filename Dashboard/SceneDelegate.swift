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
//            let window = UIWindow(windowScene: windowScene)
            let moc = PersistenceClient.persistentContainer.viewContext // todo do we still need this?
            let database = PersistenceClient()
            let network = NetworkService(database: database)
            let settings = Settings()
            
//            let dashboardTabView = DashboardTabView()
//                .environment(\.managedObjectContext, moc)
//                .environmentObject(database)
//                .environmentObject(network)
//                .environmentObject(settings)
//                .environmentObject(WatchHandler(moc: moc))
//
//            let tabHostingViewController = UIHostingController(rootView: dashboardTabView)
            
//            let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
//            let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
            
            // TODO have this use the appdelegate stuff
            UIApplication.shared.isIdleTimerDisabled = true
            let window = HeadGazeWindow(frame: UIScreen.main.bounds) // TODO: as of now, this particular initializer MUST be called. Maybe do the setup stuff on its frame's didSet?
            window.windowScene = windowScene
//            window.frame = UIScreen.main.bounds
            
            // TODO package this up
//            let trackingContainerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
//            trackingContainerViewController.addChild(addServiceViewController)
//            addServiceViewController.view.frame = trackingContainerViewController.view.frame
//            trackingContainerViewController.view.addSubview(addServiceViewController.view)
//            addServiceViewController.didMove(toParent: trackingContainerViewController)
            
            window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
