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
                .padding(10)
            
            Spacer()
            
            Text(viewModel.name)
            
            Spacer()
            
            Image(uiImage: viewModel.statusImage)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
        }
        .frame(height: 80)
    }
    
}

//struct ServiceItem_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = ServiceRowViewModel(name: "Hello", url: "", image: UIImage(), status: .unknown)
//        
//        return ServiceRow(viewModel: viewModel)
//    }
//}
