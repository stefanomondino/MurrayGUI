//
//  ContentView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct MainView: View {
    //    @EnvironmentObject var specsController: BonePackagesController
    
    @EnvironmentObject var packagesController: PackagesController
    @State private var currentTab = 0
    var body: some View {
            HSplitView {
                VSplitView {

                    TabView(selection: self.$currentTab) {
                        PackagesView()
                            .tabItem({ Text(.packagesTitle)})
                            .tag(40)
                        ContextView()
                            .tabItem({ Text("Environment")})
                            .tag(50)
                    }
                }
                .frame(minWidth: 200)
                .layoutPriority(1)
                GeometryReader { _ in
                    if self.packagesController.currentPackageController != nil {
                        PackageView(controller: self.packagesController.currentPackageController!)
                    } else {
                        Text("!")
                        .padding()
                    }
                }
                .layoutPriority(2)
            }

    }
}


//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(BonePackagesController.empty)
//    }
//}
