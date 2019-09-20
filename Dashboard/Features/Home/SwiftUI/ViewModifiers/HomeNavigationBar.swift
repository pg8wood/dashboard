//
//  HomeNavigationBar.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeNavigationBar: ViewModifier {
    
    @Binding var showingAddServices: Bool
    @Binding var serviceToEdit: ServiceModel?
    
//    var addServiceButton: some View {
//        Button(action: { self.showingAddServices.toggle() }) {
//            Image(systemName: "plus.circle")
//                .scaledToFit()
//                .accessibility(label: Text("Add Service"))
//                .imageScale(.large)
//                .frame(width: 25, height: 25)
//        }
//    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("My Services", displayMode: .large)
            .sheet(isPresented: $showingAddServices) {
                AddServiceHostView(serviceToEdit: self.serviceToEdit)
                    .onDisappear() {
                        self.serviceToEdit = nil
                }
        }
    }
}
