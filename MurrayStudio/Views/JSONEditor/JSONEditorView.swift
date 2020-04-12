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

