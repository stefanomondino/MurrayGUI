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
    var body: some View {
        GeometryReader{ g in
        HSplitView {
            VSplitView {
                PackagesView()
            }
            .frame(minWidth: 200)
            Group {
                if self.packagesController.currentPackageController != nil {
                    PackageView(controller: self.packagesController.currentPackageController!)
                } else {
                    Text("!")
                }
            }.frame(idealWidth: g.size.width * 0.66, maxWidth: .infinity, maxHeight: .infinity)
        }
        }
    }
}


//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView().environmentObject(BonePackagesController.empty)
//    }
//}
