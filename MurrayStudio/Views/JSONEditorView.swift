//
//  JSONEditorView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 06/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import Files
import MurrayKit
import Combine

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

struct JSONEditorView: View {

    @ObservedObject var controller: JSONEditorController

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if controller.isValidJSON {
                    Image(nsImageName: NSImage.statusAvailableName)
                    Text("Valid JSON")
                } else {
                    Image(nsImageName: NSImage.statusUnavailableName)
                    Text("Invalid JSON")
                }
            }
            SourceCodeView(text: self.$controller.jsonString).layoutPriority(100)
            HStack {
                Button(action: { self.controller.restore() }) { Text("Restore") }
                if controller.isValidJSON {
                    Button(action: { self.controller.save() }) { Text("Save") }
                }
            }

        }
    }
}

