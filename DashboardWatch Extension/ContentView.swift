//
//  ContentView.swift
//  DashboardWatch Extension
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

// TODO: This class is copied from ServiceListView: Determine what code can be shared and create a common ancestor =) 
struct ContentView: View {
//    @Environment(\.managedObjectContext) var moc
//    @EnvironmentObject var network: NetworkService
//    @EnvironmentObject var database: PersistenceClient
    
//    @FetchRequest(fetchRequest: PersistenceClient.allServicesFetchRequest()) var services: FetchedResults<ServiceModel>
     @EnvironmentObject var watchData: WatchData
//    var services: [String] = ["Hello world!"]
    
    // State variables are owned & managed by this view
    @State private var showingAddServices = false
    @State private var serviceToEdit: ServiceModel?
        
    var addServiceButton: some View {
        Button(action: { self.showingAddServices.toggle() }) {
            Image(systemName: "plus.circle")
                .scaledToFit()
                .accessibility(label: Text("Add Service"))
                .imageScale(.large)
                .frame(width: 25, height: 25)
        }
    }
    
    var serviceList: some View {
        List {
            ForEach(watchData.services, id: \.index) { service in
                WatchServiceRow(service: service)
                    .onAppear {
//                        self.network.updateServerStatus(for: service)
                    }
                    .onTapGesture {
//                        self.network.updateServerStatus(for: service)
                    }
                    .contextMenu {
                        Button(action: {
//                            self.serviceToEdit = service
                            self.showingAddServices.toggle()
                        }) {
                            Text("Edit Service")
                        }
                    }
            }
            .onMove(perform: moveService)
            .onDelete(perform: deleteService)
            
        }
//        .listStyle(GroupedListStyle())
    }
    
    var body: some View {
            VStack {
                if watchData.services.isEmpty {
                    EmptyStateView()
                        .padding(.top, 20)
                } else {
                    serviceList
                }
            }
                /* The conditional view above is wrapped in a VStack only to wrap it into a common ancenstor so that either conditional view may share the same modifiers.
                 I'd rather use a custom view modifier, but no views seem to render if a custom ViewModifier has a `.navigationBarItems` modifier.
                 
                 It seems like this could be accomplished without needing to wrap the conditional views. */
//                .navigationBarTitle("My Services", displayMode: .large)
//                .navigationBarItems(leading: EditButton(), trailing: addServiceButton)
//                .sheet(isPresented: $showingAddServices) {
//                    AddServiceHostView(serviceToEdit: self.serviceToEdit)
//                        .onDisappear() {
//                            self.serviceToEdit = nil
//                    }
//            }
//        }
    }
    
    /// TODO: There's an interesting animation that happens during this transition: I believe it comes from the view moving the elements, and then the backing data changing, which then re-animates the move
    private func moveService(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else {
            return // show error?
        }
        
        // Destination is an offset rather than an index, so massage it into an index
        let destinationIndex = sourceIndex > destination ? destination : destination - 1
        
//        database.swap(service: services[sourceIndex], with: services[destinationIndex])
    }
    
    private func deleteService(at offsets: IndexSet) {
        guard let deletionIndex = offsets.first else {
            return
        }
        
        let service = watchData.services[deletionIndex]
//        database.delete(service)
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
        
        return ContentView()
            .environmentObject(data)
    }
}
#endif
