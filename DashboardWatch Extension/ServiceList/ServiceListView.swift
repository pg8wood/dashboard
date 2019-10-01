//
//  ContentView.swift
//  DashboardWatch Extension
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ServiceListView: View {
    @EnvironmentObject var network: NetworkService
    @EnvironmentObject var watchData: WatchData
    
    private var serviceList: some View {
        List {
            ForEach(0..<watchData.services.count) { index in
                WatchServiceRow(service: self.$watchData.services[index])
            }
        }
    }
    
    var body: some View {
        VStack {
            if watchData.services.isEmpty {
                EmptyStateView(message: "Add some services on your iPhone to get started")
            } else {
                serviceList
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let data = WatchData()
        data.services = [
//            SimpleServiceModel(index: 0, name: "test", url: "test", lastOnlineDate: Date()),
//            SimpleServiceModel(index: 1, name: "offline server", url: "test", lastOnlineDate: .distantPast),
//            SimpleServiceModel(index: 2, name: "service with a very very very long name", url: "test", lastOnlineDate: Date())
        ]
        
        return ServiceListView()
            .environmentObject(data)
    }
}
#endif
