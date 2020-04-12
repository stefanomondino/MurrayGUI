//
//  ItemsView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 05/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit
import SwiftUI
import Combine

struct ItemsView: View {
    @ObservedObject var controller: ItemsController
    var body: some View {
        
        HSplitView {
            List(selection: self.$controller.selectedFile) {
                ForEach(self.controller.items, id: \.self) { item in
                    Section(header:
                        HStack {
                            Text(item.object.name)
                        }.tag(item.object.name)
                    ) {
                        ForEach(self.controller.files[item]!, id: \.self) { file in
                            ItemView(title: file.file.name,
                                     subtitle: file.object.to,
                                     icon: .googleMaterialDesign(.playCircleOutline))
                                .tag(file)
                        }
                    }
                }
            }
            .frame(minWidth: 200)
            .layoutPriority(1)
            GeometryReader { _ in
                if self.controller.currentFileController != nil {
                    EditorView(controller: self.controller.currentFileController!)
                        .frame(idealWidth: 500)
                    
                } else {
                    Spacer()
                }
            }.layoutPriority(2)
        }
    }
}
