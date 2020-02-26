//
//  BoneProcedureView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI

struct BoneProcedureView: View {
    @EnvironmentObject var controller: BonePackagesController

    var body: some View {

        GeometryReader { _ in
            if self.controller.selectedGroup != nil {
                VStack {
                    HStack(spacing: 4) {
                        Text("Selected group: ")
                        Text(self.controller.selectedGroup?.group.name ?? "").bold()
                        Spacer()
                        Button(action: { self.controller.showPreview.toggle() }) {
                            Text("Show/Hide preview")
                        }
                    }
                    .padding()
                    BoneFilesView()
//                    TabView {
//                        ForEach(self.controller.currentItems, id: \.self) { item in
//                            BoneFilesView(item: item)
//                                .tag(item)
//                                .tabItem { Text(item.object.name) }
//                        }
//                    }
                }
            } else {
                Text("Select a group")
            }
        }
    }
}

struct BoneProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        BoneProcedureView().environmentObject(BonePackagesController.empty)
    }
}
