//
//  ContextView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit

struct ContextView: View {
    @EnvironmentObject var controller: BoneSpecsController

    var body: some View {

        GeometryReader { _ in
            VStack {
            Form {
                ForEach(self.controller.contextManager.array.indices, id:\.self) { index in
                    HStack(spacing: 2) {
                        Text(self.controller.contextManager.array[index].key)
                        TextField(self.controller.contextManager.array[index].key, text: self.$controller.contextManager.array[index].value)
                    }
                }
            }
            Spacer()
            Button(action: { self.controller.run() }, label:  { Text("RUN") })
            }.padding()
        }
    }
}


struct ContextView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView().environmentObject(BoneSpecsController.empty)
    }
}
