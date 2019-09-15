//
//  AddServiceHostViewModel.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 9/13/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import Foundation

class AddServiceHostViewModel: ObservableObject {
    var serviceToEdit: ServiceRowViewModel?
    
    init(_ serviceToEdit: ServiceRowViewModel?) {
        self.serviceToEdit = serviceToEdit
    }
}
