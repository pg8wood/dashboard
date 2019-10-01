//
//  UIActivityIndicatorViewRepresentation.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: View {
    var body: some View {
        UIKitActivityIndicatorView()
            .scaledToFill()
    }
}

struct UIKitActivityIndicatorView: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
        
    func makeUIView(context: UIViewRepresentableContext<UIKitActivityIndicatorView>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<UIKitActivityIndicatorView>) {
        // Nothing to do
    }
}
