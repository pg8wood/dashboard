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
    var isOnline: Bool
    
    @EnvironmentObject var network: NetworkService
    @State private var isLoading: Bool = false
    @State private var disposables = Set<AnyCancellable>()
    
    private var statusImage: Image {
        if isOnline {
            return Image("check")
        } else {
            return Image(systemName: "exclamationmark.circle.fill")
        }
    }
    
    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .padding(10)
                .frame(width: 80, height: 50)
            
            Spacer()
            
            Text(name)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            Spacer()
            
            if isLoading {
                ActivityIndicatorView()
                    .frame(width: 80, height: 50)
            } else {
                statusImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 35)
                    .foregroundColor(.red)
            }
        }
        .frame(height: 90)
        .frame(minWidth: 0, maxWidth: .infinity)
        .onTapGesture {
            // TODO this tap area could be better
            self.fetchServerStatus()
        }
        .onAppear { // TODO this doesn't appear to be called when a new row is added 🤔
            self.fetchServerStatus()
        }
    }
    
    func fetchServerStatus() {
        self.isLoading = true
        
        self.network.updateServerStatus(for: self.service as! ServiceModel)
            .sink(receiveValue: { isLoading in
                withAnimation {
                    self.isLoading = isLoading
                }
                
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
