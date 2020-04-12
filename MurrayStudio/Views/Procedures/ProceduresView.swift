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

struct ProceduresView: View {
    @ObservedObject var controller: ProceduresController
    var body: some View {
        HSplitView {
            List(selection: self.$controller.selectedProcedure) {
                ForEach(self.controller.procedures, id: \.self) { item in
                    ItemView(title: item.procedure.name,
                             subtitle: "\(item.procedure.itemPaths.count) items",
                        icon: .playCircleOutline)
                        .tag(item)
                }
            }
            .frame(minWidth: 200)
            .layoutPriority(1)
            GeometryReader { _ in
                if  self.controller.currentProcedureController != nil {
                SummaryView(controller: self.controller.currentProcedureController!)
                } else {
                    Text("!")
                }
            }
            .layoutPriority(2)
        }
    }
}
