//
//  SettingsView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 1/17/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $settings.showErrorCodes) {
                        Image(systemName: "1.magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .padding(.trailing, 10)
                        
                        Text("Show error codes")
                    }
                    
                    Toggle(isOn: $settings.showFailuresFirst) {
                        Image(systemName: "exclamationmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .padding(.trailing, 10)
                        
                        Text("Show offline services first")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
        .environmentObject(Settings())
    }
}
