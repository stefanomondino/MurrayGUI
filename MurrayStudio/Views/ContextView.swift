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
                Text("Context".uppercased())
                Form {

                    Section(header: Text("Local")) {

                        ForEach(self.controller.contextManager.local.indices, id:\.self) { index in
                            HStack {
                                Text(self.controller.contextManager.local[index].key)
                                TextField(self.controller.contextManager.local[index].key, text: self.$controller.contextManager.local[index].value)
                                    .tag(self.controller.contextManager.local[index].key)
                            }

                        }
                    }
                    Section(header: Text("Environment")) {

                        ForEach(self.controller.contextManager.environment.indices, id:\.self) { index in
                            HStack {
                                Text(self.controller.contextManager.environment[index].key)
                                TextField(self.controller.contextManager.environment[index].key, text: self.$controller.contextManager.environment[index].value)
                            }.tag(self.controller.contextManager.environment[index].key)
                        }
                    }
                }
                Spacer()
                HStack {
                    Button(action: { self.controller.resetContext() }, label:  { Text("RESET") })
                    Button(action: { self.controller.run() }, label:  { Text("RUN") })
                }
            }.padding()
        }
    }
}


struct ContextView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView().environmentObject(BoneSpecsController.empty)
    }
}
