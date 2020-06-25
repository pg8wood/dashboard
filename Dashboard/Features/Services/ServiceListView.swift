//
//  ServiceListView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI
import WatchConnectivity

struct ServiceListView: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var network: NetworkService
    @EnvironmentObject var database: PersistenceClient
    @EnvironmentObject var settings: Settings
    
    @FetchRequest(fetchRequest: PersistenceClient.allServicesFetchRequest()) var allServices: FetchedResults<ServiceModel>

    // State variables are owned & managed by this view
    @State private var showingAddServices = false
    @State private var serviceToEdit: ServiceModel?
    @State private var editMode: EditMode = .inactive
    
    private var onlineServices: [ServiceModel] {
        allServices.filter {
            $0.wasOnlineRecently
        }
    }
    
    private var offlineServices: [ServiceModel] {
        allServices.filter {
            !$0.wasOnlineRecently
        }
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
    
    private var serviceList: AnyView {
        if settings.showFailuresFirst {
            // TODO: either conditionally render the sections or add a nice empty state
            return AnyView(
                List {
                    if !offlineServices.isEmpty {
                        Section(header: Text("⚠️ Offline")) {
                            serviceSection(offlineServices)
                        }
                    }
                    
                    if !onlineServices.isEmpty {
                        Section(header: Text("200 OK")) {
                            serviceSection(onlineServices)
                        }
                    }
            }
            .listStyle(GroupedListStyle())
            )
        } else {
            return AnyView(
                List {
                    serviceSection(allServices.compactMap{$0})
                }
                .listStyle(GroupedListStyle())
            )
        }
    }
    
    private func serviceSection(_ fetchedServices: [ServiceModel]) -> some View {
        ForEach(fetchedServices) { service in
            ServiceRow(name: service.name, image: service.image, url: service.url)
                /* Note that the environment modifier must go before these other modifiers,
                 otherwise only the modifer will get the environment object. The order matters! */
                .environment(\.editMode, self.$editMode)
                .simultaneousGesture(self.serviceRowTappedGesture(service))
                .contextMenu {
                    Button(action: {
                        self.editService(service)
                    }) {
                        Text("Edit Service")
                    }
            }
        }
        .onMove(perform: moveService)
        .onDelete(perform: deleteService)
    }
    
    private func serviceRowTappedGesture(_ service: ServiceModel) -> some Gesture {
        TapGesture()
            .onEnded { _ in
                guard self.editMode == .active else {
                    return
                }
                
                self.editService(service)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if allServices.isEmpty { // TODO need conditional rendering for showing offline first... might make sense to filter the "all" array
                    EmptyStateView()
                        .padding(.top, 100)
                    Spacer()
                } else {
                    serviceList
                }
            }
                // The conditional view above is wrapped in a VStack only to wrap it into a common ancenstor so that either conditional view may share the same modifiers.
                // I'd rather use a custom view modifier, but no views seem to render if a custom ViewModifier has a `.navigationBarItems` modifier.
                // It seems like this could be accomplished without needing to wrap the conditional views.
                .navigationBarTitle("My Services", displayMode: .large)
                .navigationBarItems(leading: EditButton(), trailing: addServiceButton)
                .environment(\.editMode, $editMode) // ⚠️ Note that for the editMode environment variable to work correctly with the EditButton, the environment modifier must come AFTER the navigationBarItems modifier!
                .sheet(isPresented: $showingAddServices) {
                    AddServiceHostView(serviceToEdit: self.serviceToEdit)
                        .onDisappear() {
                            self.serviceToEdit = nil
                    }
            }
        }
    }
    
    private func editService(_ service: ServiceModel) {
        self.serviceToEdit = service
        self.showingAddServices.toggle()
    }
    
    /// TODO: There's an interesting animation that happens during this transition: I believe it comes from the view moving the elements, and then the backing data changing, which then re-animates the move
    private func moveService(from source: IndexSet, to destination: Int) {
//        guard let sourceIndex = source.first else {
//            return // show error?
//        }
//
//        // Destination is an offset rather than an index, so massage it into an index
//        let destinationIndex = sourceIndex > destination ? destination : destination - 1
//
//        database.swap(service: services[sourceIndex], with: services[destinationIndex])
    }
    
    private func deleteService(at offsets: IndexSet) {
//        guard let deletionIndex = offsets.first else {
//            return
//        }
//
//        let service = services[deletionIndex]
//        database.delete(service)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceListView() // Need to mock environmentObjects to see a good preview
    }
}
#endif
