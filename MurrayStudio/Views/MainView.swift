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
    @State private var currentTab: Int = 0
    var body: some View {
        HSplitView {
            VStack {
                TabBar(selection: self.$currentTab) {
                    PackagesView()
                        .tabBarItem(0){
                            FontIconView(.googleMaterialDesign(.archive))
//                                .toolTip(.packagesTitle)
                    }

                    ContextView()
                        .tabBarItem(1){
                            FontIconView(.googleMaterialDesign(GoogleMaterialDesignType.permIdentity))
//                            .toolTip(.context)
                    }
//                        .tag(2)
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
//            if self.packagesController.currentPackageController != nil {
//                TabView {
//                    Text("Current package")
//                        .tabItem({Text("Package")})
//                        if self.packagesController.currentPackageController!.itemsController.currentFileController != nil {
//                        Text("File")
//                        .tabItem({Text("File")})
//                    }
//                    if self.packagesController.currentPackageController!.proceduresController.currentProcedureController != nil {
//                        Text("Procedure")
//                            .tabItem({Text("Procedure")})
//                    }
//
//                }
//                .frame(minWidth: 200)
//                .layoutPriority(1)
//            }
        }

    }
}


//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(PackagesController.empty)
//    }
//}


