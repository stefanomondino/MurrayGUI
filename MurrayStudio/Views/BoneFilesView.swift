//
//  BoneSpecsView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit

struct BoneFilesView: View {
    @EnvironmentObject var controller: BoneSpecsController
    //    var item: ObjectReference<BoneItem>?

    var body: some View {

        GeometryReader { _ in
            HSplitView {
                List(selection: self.$controller.selectedFile) {
                    ForEach(self.controller.items(for: self.controller.selectedGroup), id: \.self) { item in
                        Section(header: Text(item.object.name)) {
                            ForEach(self.controller.files(for: item), id:\.self) { file in
                                Text(file.name)
                            }
                        }
                    }
                }.frame(minWidth: 200)
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("From: ")
                            Text(self.controller.currentItemController.source)
                        }
                        HStack {
                            Text("To: ")
                            Text(self.controller.currentItemController.destination)
                        }
                    }.frame(idealWidth: 1000)

                    EditorView(controller: self.$controller.currentItemController)
                }

            }
        }
    }
}

struct BoneFilesView_Previews: PreviewProvider {
    static var previews: some View {
        BoneFilesView().environmentObject(BoneSpecsController.empty)
    }
}
