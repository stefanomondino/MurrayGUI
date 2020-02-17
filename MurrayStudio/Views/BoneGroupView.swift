//
//  BoneGroupView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI

struct BoneGroupView: View {
    @EnvironmentObject var controller: BoneSpecsController

    var body: some View {

        GeometryReader { _ in
            if self.controller.selectedGroup != nil {
                VStack {
                    Text(self.controller.selectedGroup?.group.name ?? "")
                TabView {
                    ForEach(self.controller.currentItems, id: \.object.name) { item in
                        BoneFilesView(item: item)
                            .tabItem { Text(item.object.name) }
                    }
                }
                }
            } else {
                Text("Select a group")
            }


        }
    }
}

struct BoneGroupView_Previews: PreviewProvider {
    static var previews: some View {
        BoneGroupView().environmentObject(BoneSpecsController.empty)
    }
}
