//
//  HomeView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.editMode) var mode
    @ObservedObject var viewModel: HomeViewModel
    @State var showingAddServices = false
    @State var serviceToEdit: ServiceRowViewModel? = nil
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var addServiceButton: some View {
        Button(action: { self.showingAddServices.toggle() }) {
            Image(systemName: "plus.circle")
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
                        .contextMenu {
                            Button(action: {
                                self.serviceToEdit = service
                                self.showingAddServices.toggle()
                            }){
                                Text("Edit Service")
                            }
                    }
                }
                .onDelete(perform: deleteRow)
            }
            .navigationBarTitle("My Services")
            .navigationBarItems(leading: EditButton(),
                                trailing: addServiceButton)
            .sheet(isPresented: $showingAddServices) {
                AddServiceHostView(viewModel: AddServiceHostViewModel(self.serviceToEdit))
                    .onDisappear() {
                        self.serviceToEdit = nil
                }
            }
        }
    }
    
    func deleteRow(at offsets: IndexSet) {
        viewModel.services.remove(atOffsets: offsets)
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = HomeViewModel(networkService: MockNetworkService())
//        
//        for i in 1...10 {
//            let serviceViewModel = ServiceRowViewModel(name: "Hello", url: "", image: UIImage(), status: .unknown)
//            
//            viewModel.services.append(serviceViewModel)
//        }
//                
//       return HomeView(viewModel: viewModel)
//    }
//}
