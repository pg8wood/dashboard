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
            PersistenceClient.shared.getStoredServices { result in
                let services = (try? result.get()) ?? [ServiceModel]()
                let serviceViewModels = services.map { ServiceRowViewModel(model: $0) }
                
                window.rootViewController = UIHostingController(rootView: HomeView(viewModel: HomeViewModel(services: serviceViewModels)))
                self.window = window
                window.makeKeyAndVisible()
            }
        }
    }
}
