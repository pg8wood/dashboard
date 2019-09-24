//
//  HomeViewControllerRepresentation.swift
//  Dashboard
//
//  Simply wraps `HomeViewController` into a SwiftUI View.
//
//  Created by Patrick Gatewood on 9/19/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct HomeHostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var serviceToEdit: ServiceModel?
    
    var cancelButton: some View {
       Button(action: {
           self.presentationMode.wrappedValue.dismiss() })
       {
           Text("Cancel")
       }
   }
     
    var body: some View {
        UIKitHomeView()
    }
}

struct UIKitHomeView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: HomeViewController, context: UIViewControllerRepresentableContext<UIKitHomeView>) {
        // nothing to do
    }
    
    func makeUIViewController(context: Context) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        return homeViewController
    }
}
