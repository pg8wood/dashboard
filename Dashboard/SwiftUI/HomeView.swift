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
        
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(viewModel.services) { service in
                ServiceRow(viewModel: service)
            }
        }
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
