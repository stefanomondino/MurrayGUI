//
//  UserDefaults.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation

enum Defaults: String {
    case lastProject = "murrayStudio.lastURL"
}

@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: Defaults
    var storage: UserDefaults = .standard

    var wrappedValue: Value? {
        get { storage.value(forKey: key.rawValue) as? Value }
        set { storage.setValue(newValue, forKey: key.rawValue) }
    }
}
