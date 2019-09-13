//
//  AddServiceView.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/13/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import SwiftUI

struct AddServiceHostView: View {
    @ObservedObject var viewModel: AddServiceHostViewModel
    
    init(viewModel: AddServiceHostViewModel) {
        self.viewModel = viewModel
    }
     
    var body: some View {
        NavigationView {
            AddServiceView()
                .navigationBarTitle("\(self.viewModel.serviceToEdit?.name != nil ? "Edit" : "Add") Service")
        }
    }
}

struct AddServiceView: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: AddServiceViewController, context: UIViewControllerRepresentableContext<AddServiceView>) {
        // nothing to do
    }
    
    func makeUIViewController(context: Context) -> AddServiceViewController {
        let storyboard = UIStoryboard(name: "AddServiceViewController", bundle: nil)
        let addServiceViewController = storyboard.instantiateViewController(withIdentifier: "AddServiceViewController") as! AddServiceViewController
//        addServiceViewController.mode = serviceToEdit == nil ? .create : .edit
        addServiceViewController.mode = .create
        addServiceViewController.serviceDelegate = nil
        addServiceViewController.serviceToEdit = nil

//        let navigationController = UINavigationController(rootViewController: addServiceViewController)
        
        return addServiceViewController
    }
}

struct AddServiceView_Previews: PreviewProvider {
    static var previews: some View {
        AddServiceView()
    }
}
