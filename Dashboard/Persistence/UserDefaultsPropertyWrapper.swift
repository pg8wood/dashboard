//
//  UserDefault.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 1/17/20.
//  Copyright © 2020 Patrick Gatewood. All rights reserved.
//
//  Based off this wonderful answer: https://stackoverflow.com/questions/56822195/how-do-i-use-userdefaults-with-swiftui

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
