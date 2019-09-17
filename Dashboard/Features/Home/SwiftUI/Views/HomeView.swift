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
//    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var services: ServiceList
    @State var showingAddServices = false
    @State var serviceToEditIndex: Int?
    
//    init(viewModel: HomeViewModel) {
//        self.viewModel = viewModel
//    }
//
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
                ForEach(services.services, id: \.url) { service in
                    Text("\(service.name)")
//                    ServiceRow(name: service.name, url: service.url, image: service.image)
                        .contextMenu {
                            Button(action: {
                                self.serviceToEditIndex = self.services.services.firstIndex(of: service)
                                self.showingAddServices.toggle() })
                            {
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
                AddServiceHostView(serviceToEdit: self.services.services[self.serviceToEditIndex!]) // TODO no force unwrp
                    .onDisappear() {
                        // TODO: instead of reloading everything we should get which was
                        // created/changed and only update that. Might make sense to bind
                        // services to the database rather than an in-memory array
//                        self.viewModel.loadServices()
                        
                        self.serviceToEditIndex = nil
//                        self.services.services[0].name = "test"
                }
            }
        }
    }
    
    func deleteRow(at offsets: IndexSet) {
//        services.remove(atOffsets: offsets)
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
