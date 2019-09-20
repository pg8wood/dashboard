//
//  HomeTabView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/19/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeTabView: View {
    var body: some View {
        TabView {
            ServiceListView()
                .tabItem {
                    Image(systemName: "13.square")
                        .imageScale(.large)
                    Text("SwiftUI")
            }
            
            UIKitHomeView()
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    Image(systemName: "12.square")
                        .imageScale(.large)
                    Text("UIKit")
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView()
    }
}
