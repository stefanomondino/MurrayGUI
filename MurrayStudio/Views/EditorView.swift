//
//  DoubleEditorView.swift
//  MurrayGUI
//
//  Created by synesthesia on 24/06/2019.
//  Copyright © 2019 synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import Files
import MurrayKit

struct EditorView: View {
    @ObservedObject var controller: BoneItemController
    @State private var toggleRight: Bool = false
    
    var body: some View {

        VStack {
            HStack {
                Button(action:{ self.toggleRight.toggle() }) {
                    Text("Preview")
                }
                .padding()
                .background(self.toggleRight ? Color.blue : Color.clear)
                }

            HStack {
                SourceCodeView(text: self.$controller.text)
                if self.toggleRight {
                    SourceCodeView(text: self.$controller.resolved)
                }
            }
        }
    }
}
