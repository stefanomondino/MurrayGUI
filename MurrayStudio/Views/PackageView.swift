//
//  PackageView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 04/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI

struct PackageView: View {
    @ObservedObject var controller: PackageController
    var body: some View {
        GeometryReader { g in
            VStack {
                VStack {
                    Text(self.controller.package.object.name).textStyle(TitleStyle())
                    Text(self.controller.package.object.name).textStyle(SubtitleStyle())
                }
                TabView {
                    ItemsView(controller: self.controller.itemsController)
                        .tabItem { Text("Items") }
                        .tag(0)
                    ProceduresView(controller: self.controller.proceduresController)
                        .tabItem { Text("Procedures") }
                        .tag(1)
                }
            }
        }
    }
}

