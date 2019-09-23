//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI
import Combine

struct ServiceRow: View {
    var service: ServiceModel
    var name: String
    var url: String
    var image: UIImage
    var statusImage: UIImage
    
    @EnvironmentObject var network: NetworkService
    @State private var isLoading: Bool = false
    @State private var disposables = Set<AnyCancellable>()
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .padding(10)
                .frame(width: 80, height: 50)
            
            Spacer()
            
            Text(name)
            
            Spacer()
            
            if isLoading {
                // TODO my website is so fast that it doesn't look like the view even changes when pinging it. Need a minimum time to show the loading indicator. (Caddy server rocks!)
                ActivityIndicatorView()
                    .frame(width: 80, height: 50)
            } else {
                Image(uiImage: statusImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 35)
            }
        }
        .onAppear { // TODO this doesn't appear to be called when a new row is added 🤔
            self.fetchServerStatus()
        }
        .onTapGesture {
            self.fetchServerStatus()
        }
        .frame(height: 90)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground).cornerRadius(15))
    }
    
    private func fetchServerStatus() {
        self.isLoading = true
        self.network.updateServerStatus(for: self.service)
            .sink(receiveValue: { isLoading in
                self.isLoading = isLoading
            })
        .store(in: &disposables) // whoops, if we don't retain this cancellable object the network data task will be cancelled
    }
}

//#if DEBUG
//struct ServiceItem_Previews: PreviewProvider {
//    static var previews: some View {
//        return ServiceRow(name: "Test Service", url: "test.com", image: UIImage(named: "missing-image")!, statusImage: UIImage(named: "check")!, isLoading: false)
//    }
//}
//#endif
