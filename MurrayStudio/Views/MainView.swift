//
//  ContentView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var specsController: BoneSpecsController
    var body: some View {
        GeometryReader{ g in
        HSplitView {
            BoneSpecsView().frame(idealWidth: 300)
            BoneGroupView().frame(idealWidth: g.size.width, maxWidth: .infinity, maxHeight: .infinity)


            ContextView().frame(idealWidth: 300)
        }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(BoneSpecsController.empty)
    }
}
