//
//  EmptyStateView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    var message = "Add some services to get started"
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "moon.stars")
                .resizable()
                .frame(width: 50, height: 50)
                .scaledToFit()
            
            Text(message)
                .font(.callout)
                .padding(.top, 20)
        }
    }
}

// Note that the PreviewProvider will change devices according to the scheme chosen in Xcode
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(message: "Add some services on your iPhone to get started")
    }
}
