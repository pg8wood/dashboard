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
//    var isOnline: Bool // TODO this can be removed from the CoreData object
    
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var network: NetworkService
    @EnvironmentObject var settings: Settings
    
    @State private var isLoading: Bool = false
    @State private var disposables = Set<AnyCancellable>()
    @State private var serverResponse: Result<Int, URLError> = .failure(URLError(.unknown))
    
    // AnyView type-erasure: https://www.hackingwithswift.com/quick-start/swiftui/how-to-return-different-view-types
    private var accessoryView: AnyView {
        if isLoading {
            return AnyView(
                ActivityIndicatorView()
                    .frame(width: 80, height: 50)
            )
        } else {
            return AnyView(statusView)
        }
    }
    
    private var statusView: AnyView {
        
        func errorView(message: String) -> AnyView {
            return AnyView(
                VStack(spacing: 10) {
                    accessoryImage(from: Image(systemName: "exclamationmark.circle.fill"))
                    
                    if $settings.showErrorCodes.wrappedValue == true {
                        Text(message)
                            .font(.caption)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: 80) // TODO might be good to make this a constant in an "errorView" or "accessoryView" class
            )
        }
        
        switch serverResponse {
        case .success(let statusCode):
            guard statusCode == 200 else {
                return errorView(message: "\(statusCode)")
            }
            
            return AnyView(accessoryImage(from: Image("check")))
        case .failure(let error):
            let errorMessage: String
            
            switch error.code {
            case .badURL:
                errorMessage = "Invalid URL"
            case .cannotFindHost, .cannotConnectToHost:
                errorMessage = "No response"
            case .badServerResponse:
                errorMessage = "Invalid response"
            default:
                errorMessage = error.localizedDescription
            }
            
            return errorView(message: errorMessage)
        }
    }
    
    private func accessoryImage(from image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 35)
            .foregroundColor(.red)
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
            
            if self.editMode?.wrappedValue == .inactive {
                accessoryView
                    .animation(.easeInOut)
            }
        }
        .frame(height: 90)
        .frame(minWidth: 0, maxWidth: .infinity)
        .onTapGesture {
            guard self.editMode?.wrappedValue == .inactive else { return }
            self.fetchServerStatus()
        }
        .onAppear {
            self.fetchServerStatus()
        }
    }
    
    func fetchServerStatus() {
        self.isLoading = true
        
        self.network.fetchServerStatusCode(for: service.url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    self.serverResponse = .failure(error)
                    self.isLoading = false
                }
            }, receiveValue: { statusCode in
                self.serverResponse = .success(statusCode)
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
