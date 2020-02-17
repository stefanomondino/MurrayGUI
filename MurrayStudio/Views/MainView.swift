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
        HSplitView {
            BoneSpecsView()
            BoneGroupView()
            ContextView()
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(BoneSpecsController.empty)
    }
}
