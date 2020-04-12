//
//  JSONEditorController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 12/04/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class JSONEditorController: ObservableObject {

    @Published var jsonString: String = ""
    @Published var isValidJSON: Bool = true
    var cancellables: [AnyCancellable] = []
    private let externalJSON: Binding<String>
    init(_ json: Binding<String>) {
        self.externalJSON = json
        jsonString = json.wrappedValue
        $jsonString.map { string -> Bool in
            if let data = string.data(using: .utf8),
                let _ = try? JSONSerialization.jsonObject(with: data, options: []) {
                return true
            } else {
                return false
            }
        }
        .assign(to: \.isValidJSON, on: self)
        .store(in: &cancellables)
    }

    func save() {
        self.externalJSON.wrappedValue = self.jsonString
    }
    func restore() {
        self.jsonString = self.externalJSON.wrappedValue
    }
}
