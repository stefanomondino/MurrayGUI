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
            HStack {
                List(selection: self.$controller.selectedFile) {
                    ForEach(self.controller.items(for: self.controller.selectedGroup), id: \.self) { item in

                        Section(header: Text(item.object.name)) {
                            ForEach(self.controller.files(for: item), id:\.self) { file in
                            Text(file.name)
                        }
                    }
                }
            }
            .frame(width: 300)

            if self.controller.currentItemController != nil {
                EditorView(controller: self.controller.currentItemController!)
            } else {
                Spacer()
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
