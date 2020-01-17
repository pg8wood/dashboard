//
//  DashboardTabView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 1/17/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct DashboardTabView: View {
    var body: some View {
        TabView {
            ServiceListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Services")
            }
            
            Text("Preferences")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct DashboardTabs_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTabView()
    }
}
