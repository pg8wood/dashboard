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
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    if let windowScene = scene as? UIWindowScene {
        let window = UIWindow(windowScene: windowScene)
        let viewModel = HomeViewModel(networkService: NetworkService())
        
        // Testing data. Need to remove
        viewModel.services.append(ServiceRowViewModel(name: "My website", url: "https://patrickgatewood.com"))
        viewModel.services.append(ServiceRowViewModel(name: "Test Service"))

        window.rootViewController = UIHostingController(rootView: HomeView(viewModel: viewModel))
        self.window = window
        window.makeKeyAndVisible()
    }
  }
}
