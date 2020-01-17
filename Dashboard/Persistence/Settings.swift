//
//  Settings.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 1/17/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//

import Foundation
import Combine

final class Settings: ObservableObject {
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @UserDefault("showErrorCodes", defaultValue: false)
    var showErrorCodes: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}
