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

struct ReplacementView: View {
    @EnvironmentObject var specController: BonePackagesController
    @Binding var controller: BoneReplacementController

    var body: some View {

        VStack {
            HStack {
                SourceCodeView(text: self.$controller.text)
                if self.specController.showPreview {
                    SourceCodeView(text: self.$controller.resolved)
                }
            }
        }
    }
}
