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
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var network: NetworkService
    @EnvironmentObject var settings: Settings
    
    let name: String
    let image: UIImage
    let url: String
    
    @State private var isLoading: Bool = false
    @State private var hasAppeared = false
    @State private var disposables = Set<AnyCancellable>()
    @State private var serverResponse: Result<Int, URLError> = .failure(URLError(.unknown))
    @State private var lastResponseTime: TimeInterval?
    
    private let accessoryViewWidth: CGFloat = 80
    
    private var responseTimeDescription: String {
        guard let responseTime = lastResponseTime else { return "Response time unknown" }
        
        return "\(Int(responseTime * 1000)) ms"
    }
    
    // AnyView type-erasure: https://www.hackingwithswift.com/quick-start/swiftui/how-to-return-different-view-types
    private var accessoryView: AnyView {
        if isLoading {
            return AnyView(
                ActivityIndicatorView()
                    .frame(width: accessoryViewWidth, height: 50)
            )
        } else {
            return AnyView(statusView)
        }
    }
    
    private var statusView: some View {
        let image: Image
        let message: String
        
        switch serverResponse {
        case .success(let statusCode):
            if statusCode != 200 {
                image = Image(systemName: "exclamationmark.circle.fill")
                message = "\(statusCode)"
            } else {
                image = Image("check")
                message = responseTimeDescription
            }
        case .failure(let error):
            image = Image(systemName: "exclamationmark.circle.fill")
            message = error.shortLocalizedDescription
        }
        
        return VStack(spacing: 10) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 35)
                .foregroundColor(.red)
            
            if $settings.showErrorCodes.wrappedValue == true {
                Text(message)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: accessoryViewWidth)
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
            self.fetchServerStatus()
        }
        .onAppear {
            guard !self.hasAppeared else {
                return
            }
            
            self.hasAppeared = true
            self.fetchServerStatus()
        }
    }
    
    func fetchServerStatus() {
        guard self.editMode?.wrappedValue == .inactive else { return }
        
        self.isLoading = true
        let loadingStartDate = Date()
        
        self.network.fetchServerStatusCode(for: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.serverResponse = .failure(error)
                }
                
                self.requestDidFinish(startingDate: loadingStartDate)
            }, receiveValue: { statusCode in
                self.serverResponse = .success(statusCode)
            })
            .store(in: &disposables) // whoops, if we don't retain this cancellable object the network data task will be cancelled
    }
    
    private func requestDidFinish(startingDate: Date) {
        let timeSpentLoading = Date().timeIntervalSince(startingDate)
        let minimumLoadingTime: TimeInterval = 0.5
        let secondsToContinueLoading = abs(minimumLoadingTime - timeSpentLoading)
        
        self.lastResponseTime = timeSpentLoading
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + secondsToContinueLoading) {
            self.isLoading = false
        }
    }
}

#if DEBUG
struct ServiceItem_Previews: PreviewProvider {
    static var previews: some View {
        return ServiceRow(name: "Test Service", image: UIImage(named: "missing-image")!, url: "https://patrickgatewood.com")
    }
}
#endif


