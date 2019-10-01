//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI
import Combine

// TODO: most of this is copied from the iOS version. Extract the commonalitites to make this more DRY
struct WatchServiceRow: View {
    var service: SimpleServiceModel
//    var name: String
//    var url: String
////    var image: UIImage
//    var isOnline: Bool
    
//    @EnvironmentObject var network: NetworkService
    @State private var isLoading: Bool = false
    @State private var disposables = Set<AnyCancellable>()
    
    private var statusImage: some View {
        let image = Image(systemName: service.wasOnlineRecently ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            .resizable()
            .foregroundColor(service.wasOnlineRecently ? .green : .red)
        
        return image
            .frame(width: 25, height: 25)
    }
    
    var body: some View {
        HStack {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .padding(10)
//                .frame(width: 80, height: 50)
            
//            Spacer()
            
            Text(service.name)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 5)
            
            Spacer()
            
            if isLoading {
                Text("loading...")
//                ActivityIndicatorView()
                    .frame(width: 80, height: 50)
            } else {
                statusImage
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 5)
//        .frame(height: 90)
//        .frame(minWidth: 0, maxWidth: .infinity)
        .onTapGesture {
            // TODO this tap area could be better
            self.fetchServerStatus()
        }
        .onAppear { // TODO this doesn't appear to be called when a new row is added 🤔
            self.fetchServerStatus()
        }
    }
    
    func fetchServerStatus() {
//        self.isLoading = true
//        
//        self.network.updateServerStatus(for: self.service)
//            .sink(receiveValue: { isLoading in
//                withAnimation {
//                    self.isLoading = isLoading
//                }
//                
//            })
//            .store(in: &disposables) // whoops, if we don't retain this cancellable object the network data task will be cancelled
    }
}

#if DEBUG
struct ServiceItem_Previews: PreviewProvider {
    static var previews: some View {
        return WatchServiceRow(service: SimpleServiceModel(index: 0, name: "test", url: "test", lastOnlineDate: Date()))
    }
}
#endif
