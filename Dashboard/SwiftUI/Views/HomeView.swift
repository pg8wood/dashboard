//
//  HomeView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @State var showingAddServices = false
        
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var addServiceButton: some View {
        Button(action: { self.showingAddServices.toggle() }) {
            Image(systemName: "plus.circle")
                .resizable()
                .scaledToFit()
                .accessibility(label: Text("Add Service"))
                .imageScale(.large)
                .frame(width: 25, height: 25)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.services) { service in
                    ServiceRow(viewModel: service)
                }
                .onDelete(perform: deleteRow)
            }
            .navigationBarTitle("My Services")
            .navigationBarItems(leading: EditButton(),
                                trailing: addServiceButton)
            .sheet(isPresented: $showingAddServices) {
                AddServiceView()
            }
        }
    }
    
    func deleteRow(at offsets: IndexSet) {
        viewModel.services.remove(atOffsets: offsets)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeViewModel(networkService: MockNetworkService())
        
        for i in 1...10 {
            let serviceViewModel = ServiceRowViewModel(networkService: MockNetworkService())
            serviceViewModel.name = "Service \(i)"
            
            viewModel.services.append(serviceViewModel)
        }
                
       return HomeView(viewModel: viewModel)
    }
}
