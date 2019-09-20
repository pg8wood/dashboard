//
//  EmptyStateView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "moon.stars")
                .resizable()
                .frame(width: 50, height: 50)
                .scaledToFit()
            
            Text("Add some services to get started")
                .font(.callout)
                .padding(.top, 20)
            
            Spacer()
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
