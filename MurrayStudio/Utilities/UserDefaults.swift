//
//  UserDefaults.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation

enum Defaults: String {
    case lastOpened = "murrayStudio.lastOpened"
    case history = "murrayStudio.history"
}

@propertyWrapper struct UserDefaultsBacked<Value> {
    let key: Defaults
    var storage: UserDefaults = .standard

    var wrappedValue: Value? {
        get { storage.value(forKey: key.rawValue) as? Value }
        set { storage.setValue(newValue, forKey: key.rawValue) }
    }
}

@propertyWrapper struct CodableUserDefaultsBacked<Value: Codable> {
    let key: Defaults
    var storage: UserDefaults = .standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    var wrappedValue: Value? {
        get {
            guard let data = storage.value(forKey: key.rawValue) as? Data,
                let value = try? decoder.decode(Value.self, from: data) else {
                    return nil
            }
            return value

        }
        set {
            let encoded = try? encoder.encode(newValue)
            storage.setValue(encoded, forKey: key.rawValue) }
    }
}
