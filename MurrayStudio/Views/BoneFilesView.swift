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

    enum Action: Identifiable {
        case rename
        case new(ObjectReference<BoneItem>)
        case delete

        var id: String {
            switch self {
            case .rename: return "rename"
            case .delete: return "delete"
            case .new(let i): return "new_\(i.object)"
            }
        }

        var sheetTitle: String {
            switch self {
            case .rename: return "Rename File"
            case .new: return "New File"
            case .delete: return "Delete File"
            }
        }

        var saveActionTitle: String {
            switch self {
            case .rename: return "Rename"
            case .new: return "New"
            case .delete: return "Delete"
            }
        }
        var newItem: ObjectReference<BoneItem>? {
            switch self {
            case .new(let o): return o
            default: return nil
            }
        }
    }

    @EnvironmentObject var controller: BoneSpecsController
    //    var item: ObjectReference<BoneItem>?
    @State var action: Action?
    @State var newItemName: String = ""
    @State var newItemDestination: String = ""
    var body: some View {

        GeometryReader { _ in
            HSplitView {
                List(selection: self.$controller.selectedFile) {
                    ForEach(self.controller.items(for: self.controller.selectedGroup), id: \.self) { item in
                        Section(header:
                            HStack(spacing: 2)  {
                                Text(item.object.name)
                                Spacer()
                                Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                                    .controlSize(.regular)
                                    .onTapGesture {
                                        self.action = .new(item)
                                }
                            }

                            .sheet(item: self.$action) { action in
                                if action.newItem != nil {
                                    GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Create", confirm: {
                                        self.controller.addFile(named: self.newItemName, destination: self.newItemDestination, to: action.newItem!)
                                    }, content: {
                                        VStack {
                                            Text("\(action.newItem!.object.name)")
                                            TextField("File name", text: self.$newItemName)
                                            TextField("Destination", text: self.$newItemDestination)
                                        }
                                    })
                                } else {
                                    EmptyView()
                                }
                            }.tag(item)
                        ) {
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
