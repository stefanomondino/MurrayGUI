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
    @EnvironmentObject var packagesController: PackagesController
    @ObservedObject var controller: EditorController

    var body: some View {

        VStack {
            HStack {
                SourceCodeView(text: self.$controller.text)
                if self.controller.showPreview {
                    SourceCodeView(text: self.$controller.resolved)
                }
            }
        }
    }
}
