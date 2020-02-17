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
    var item: ObjectReference<BoneItem>?

    var body: some View {

        GeometryReader { _ in
            HStack {
                List(selection: self.$controller.selectedFile) {
                    //                if self.controller.files(for: self.item).isEmpty {
                    //                    Text("No file found in current group")
                    //                } else {
                    Section(header: Text("Files")) {
                        ForEach(self.controller.files(for: self.item), id:\.self) { file in
                            Text(file.name)
                        }
                        //                    }
                    }
                }
                .frame(width: 200)

                if self.controller.currentItemController != nil {
                    EditorView(controller: self.controller.currentItemController!)
                } else {
                    Text("Select a file")
                    Spacer()
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
