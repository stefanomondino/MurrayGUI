//
//  ContentView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var specsController: BonePackagesController
    var body: some View {
        GeometryReader{ g in
        HSplitView {
            VSplitView {
                BonePackagesView().frame(idealWidth: 300, idealHeight: 400)
                ContextView().frame(idealHeight: 400)
            }.frame(idealWidth: 300)
            BoneProcedureView().frame(idealWidth: g.size.width - 300, maxWidth: .infinity, maxHeight: .infinity)



        }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(BonePackagesController.empty)
    }
}
