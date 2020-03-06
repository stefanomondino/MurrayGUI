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
    @EnvironmentObject var packagesController: PackagesController
    @ObservedObject var controller: PackageController
    @State private var currentTab = 10
    var body: some View {
        VSplitView {
            GeometryReader { _ in
            VStack {
                VStack {
                    Text(self.controller.package.object.name).textStyle(TitleStyle())
                    Text(self.controller.package.object.name).textStyle(SubtitleStyle())
                }
                TabView(selection: self.$currentTab) {
                    ItemsView(controller: self.controller.itemsController)
                        .tabItem { Text("Items") }
                        .tag(10)
                        .padding()
                    ProceduresView(controller: self.controller.proceduresController)
                        .tabItem { Text("Procedures") }
                        .tag(20)
                    .padding()
                }
            }
            }
        .padding()
            .layoutPriority(2)

            VStack {
                Text("Context")
                ForEach(self.packagesController.contextController.local.indices, id:\.self) { index in
                    HStack {
                        Text(self.packagesController.contextController.local[index].key)
                        TextField(self.packagesController.contextController.local[index].key, text: self.$packagesController.contextController.local[index].value)
                            .tag(self.packagesController.contextController.local[index].key)
                    }
                }
            }
        .padding()
            .layoutPriority(1)
        }
    }
}

