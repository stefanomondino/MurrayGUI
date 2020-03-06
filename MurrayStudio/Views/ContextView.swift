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
    @EnvironmentObject var controller: PackagesController
    var body: some View {
        JSONEditorView(controller: controller.contextController.environmentEditor)
    }
}


//
//struct ContextView: View {
//    @EnvironmentObject var controller: PackagesController
//
//    var body: some View {
//
//
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Context").bold()
//                Form {
//
//                    Section(header: Text("Local")) {
//
//                        ForEach(self.controller.contextController.local.indices, id:\.self) { index in
//                            HStack {
//                                Text(self.controller.contextController.local[index].key)
//                                TextField(self.controller.contextController.local[index].key, text: self.$controller.contextController.local[index].value)
//                                    .tag(self.controller.contextController.local[index].key)
//                            }
//
//                        }
//                    }
//                    Section(header: Text("Environment")) {
//
//                        ForEach(self.controller.contextController.environment.indices, id:\.self) { index in
//                            HStack {
//                                Text(self.controller.contextController.environment[index].key)
//                                TextField(self.controller.contextController.environment[index].key, text: self.$controller.contextController.environment[index].value)
//                            }.tag(self.controller.contextController.environment[index].key)
//                        }
//                    }
//                }
//                Spacer()
////                HStack {
////                    Button(action: { self.controller.resetContext() }, label:  { Text("RESET") })
////                    Button(action: { self.controller.run() }, label:  { Text("RUN") }).alert(isPresented: self.$controller.showErrorAlert, content: {
////                        Alert(title: Text("Error"), message: Text(self.controller.error?.localizedDescription ?? ""))
////                    })
////                }
//            }.padding()
//
//    }
//}
