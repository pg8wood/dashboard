//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ServiceRow: View {
    @ObservedObject var viewModel: ServiceRowViewModel
    
    init(viewModel: ServiceRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFill()
                .padding(10)
            
            Spacer()
            
            Text(viewModel.name)
            
            Spacer()
            
            Image(uiImage: viewModel.statusImage)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
            
            Spacer()
        }
        .frame(height: 100)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
    
}

struct ServiceItem_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ServiceRowViewModel(networkService: MockNetworkService())
        viewModel.name = "My Website"
        return ServiceRow(viewModel: viewModel)
    }
}
