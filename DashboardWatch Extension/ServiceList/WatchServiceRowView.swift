//
//  ServiceItem.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/11/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI
import Combine

struct WatchServiceRow: View {
    @EnvironmentObject var network: NetworkService
    @Binding var service: SimpleServiceModel
    @State private var isLoading: Bool = false
    @State private var disposables = Set<AnyCancellable>()
    
    private var statusImage: some View {
        Image(systemName: service.wasOnlineRecently ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            .foregroundColor(service.wasOnlineRecently ? .green : .red)
    }
    
    var body: some View {
        HStack {
            Text(service.name)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 5)
            
            Spacer()
            
            if isLoading {
                Image(systemName: "ellipsis")
                    .frame(width: 25, height: 25)
            } else {
                statusImage
                    .padding(.leading, 5)
                    .frame(width: 25, height: 25)
                    
            }
        }
        .padding(.horizontal, 5)
        .onTapGesture {
            self.fetchServerStatus()
        }
        .onAppear {
            self.fetchServerStatus()
        }
    }
    
    // Normally networking on watchOS is discouraged, but since this is such a simple request, I'm gonna ignore it.
    // If the request gets ANY more complicated, I'll move to having the watch app request cached data from the iOS app.
    func fetchServerStatus() {
        self.network.fetchServerStatusCode(for: service.url)
            .handleEvents(receiveSubscription: { _ in
                self.isLoading = true
            }, receiveCompletion: { _ in
                withAnimation(.easeIn(duration: 0.5)) {
                    self.isLoading = false
                }
            }, receiveCancel: {
                withAnimation(.easeIn(duration: 0.5)) {
                    self.isLoading = false
                }
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    DispatchQueue.main.async {
                        self.service.lastOnlineDate = .distantPast
                    }
                }
            }, receiveValue: { responseCode in
                DispatchQueue.main.async {
                    guard 200..<300 ~= responseCode else {
                        
                        self.service.lastOnlineDate = .distantPast
                        return
                    }
                    
                    self.service.lastOnlineDate = Date()
                }
            })
            .store(in: &disposables)
    }
}

//#if DEBUG
//struct ServiceItem_Previews: PreviewProvider {
//    static var previews: some View {
//        let model = SimpleServiceModel(index: 0, name: "test", url: "test", lastOnlineDate: Date())
//        
//        return WatchServiceRow(service: .constant(model))
//    }
//}
//#endif
