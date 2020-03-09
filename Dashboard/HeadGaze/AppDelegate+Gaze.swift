//
//  AppDelegate+Gaze.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/8/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit

extension AppDelegate {
    
    private struct Storage {
        static var _window: UIWindow?
    }
    
    var window: UIWindow? {
        get {
            Storage._window
        } set {
            Storage._window = newValue
        }
    }
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        
//        application.isIdleTimerDisabled = true
//        let window = HeadGazeWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//        window.makeKeyAndVisible()
//        self.window = window
//        return true
//    }
}
