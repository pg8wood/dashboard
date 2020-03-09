//
//  DashboardTabHostingViewController.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 3/9/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import UIKit
import SwiftUI

class DashboardTabHostingViewController: UIHostingController<AnyView> {
    
    required init?(coder aDecoder: NSCoder) {
        let moc = PersistenceClient.persistentContainer.viewContext // todo do we still need this?
        let database = PersistenceClient()
        let network = NetworkService(database: database)
        let settings = Settings()
        
        let dashboardTabView = AnyView(
            DashboardTabView()
                .environment(\.managedObjectContext, moc)
                .environmentObject(database)
                .environmentObject(network)
                .environmentObject(settings)
                .environmentObject(WatchHandler(moc: moc)))
        
        super.init(coder: aDecoder, rootView: dashboardTabView)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        guard segue.identifier == "ContentViewControllerSegue" else {
//            return
//        }
//
//        installRootView()
//    }
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        

        // Do any additional setup after loading the view.
    }

}
