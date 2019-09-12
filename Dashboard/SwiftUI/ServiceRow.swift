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
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
            Text(viewModel.name)
            Image(uiImage: viewModel.statusImage)
                .resizable()
            .scaledToFit()
        }
         .frame(height: 50)
    }
}

struct ServiceItem_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ServiceRowViewModel(networkService: MockNetworkService())
        viewModel.name = "My Website"
        return ServiceRow(viewModel: viewModel)
    }
}
