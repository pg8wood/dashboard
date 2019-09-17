//
//  AddServiceView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/13/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct AddServiceHostView: View {
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
        AddServiceView(serviceToEdit: serviceToEdit) // should the viewmodel's model be exposed here?
    }
}

struct AddServiceView: UIViewControllerRepresentable {
    var serviceToEdit: ServiceModel?
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<AddServiceView>) {
        // nothing to do
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
        let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
        addServiceViewController.mode = serviceToEdit == nil ? .create : .edit
        addServiceViewController.serviceDelegate = nil
        addServiceViewController.serviceToEdit = serviceToEdit
        
        let navigationController = UINavigationController(rootViewController: addServiceViewController)
        
        return navigationController
    }
}

//struct AddServiceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddServiceView()
//    }
//}
