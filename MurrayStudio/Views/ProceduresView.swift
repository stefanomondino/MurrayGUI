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
        GeometryReader { g in
            List(selection: self.$controller.selectedProcedure) {
                ForEach(self.controller.procedures, id: \.self) { item in
                    Text(item.procedure.name)
                        .tag(item)
                }
            }
        }
    }
}
