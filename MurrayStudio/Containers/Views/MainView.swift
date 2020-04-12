//
//  ContentView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var packagesController: PackagesController
    @State private var currentTab: Int = 0
    var body: some View {
        HSplitView {
            VStack {
                TabBar(selection: self.$currentTab) {
                    PackagesView()
                        .tabBarItem(0){
                            MaterialDesignIconView(.archive)
                                .toolTip(.packagesTitle)
                    }

                    ContextView()
                        .tabBarItem(1){
                            MaterialDesignIconView(.permIdentity)
                                .toolTip(.context)
                    }
                }
            }
            .frame(minWidth: 200)
            .layoutPriority(1)
            GeometryReader { _ in
                if self.packagesController.currentPackageController != nil {
                    PackageView(controller: self.packagesController.currentPackageController!)
                } else {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Empty")
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .layoutPriority(2)
        }

    }
}
