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
        case newItem
        case newFile(ObjectReference<BoneItem>)
        case delete

        var id: String {
            switch self {
            case .rename: return "rename"
            case .newItem: return "newItem"
            case .delete: return "delete"
            case .newFile(let i): return "new_\(i.object)"
            }
        }
        var isNewItem: Bool {
            switch self {
            case .newItem: return true
            default: return false
            }
        }
        var newFile: ObjectReference<BoneItem>? {
            switch self {
            case .newFile(let o): return o
            default: return nil
            }
        }
    }

    @EnvironmentObject var controller: BoneSpecsController
    //    var item: ObjectReference<BoneItem>?
    @State var action: Action?
    @State var newFileName: String = ""
    @State var newFileDestination: String = ""
    @State var newItemText: String = ""
    var body: some View {

        GeometryReader { _ in
            HSplitView {
                VStack {
                    List(selection: self.$controller.selectedFile) {
                        ForEach(self.controller.items(for: self.controller.selectedGroup), id: \.self) { item in
                            Section(header:
                                HStack(spacing: 2)  {
                                    Text(item.object.name)
                                    Spacer()
                                    Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                                        .controlSize(.regular)
                                        .onTapGesture {
                                            self.action = .newFile(item)
                                    }
                                }


                                .tag(item)
                            ) {
                                ForEach(self.controller.files(for: item), id:\.self) { file in
                                    Text(file.name)
                                }
                            }
                        }
                    }
                    HStack {
                        Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                            .controlSize(.regular)
                            .onTapGesture {
                                self.action = .newItem
                        }
                    }
                }.frame(minWidth: 200)
                

                VStack(alignment: .leading) {
                    HStack {
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
                        Spacer()
                        Button("Restore", action: { self.controller.currentItemController.restore() })
                        Button("Save", action: { self.controller.currentItemController.save() })
                    }.padding()

                    EditorView(controller: self.$controller.currentItemController)
                }.sheet(item: self.$action) { action in
                    if action.newFile != nil {
                        GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Create", confirm: {
                            self.action = nil
                            self.controller.addFile(named: self.newFileName, destination: self.newFileDestination, to: action.newFile!)
                        }, content: {
                            VStack {
                                Text("\(action.newFile!.object.name)")
                                TextField("File name", text: self.$newFileName)
                                TextField("Destination", text: self.$newFileDestination)
                            }
                        })
                    }
                    else if action.isNewItem {
                        BoneItemPickerView( items: self.controller.allItems(), callback: { item, text in
                            if let group = self.controller.selectedGroup {
                                self.action = nil
                                self.controller.addItem(item, named: text, to: group)
                            }
                        })
                    }
                    else {
                        EmptyView()
                    }
                }
                .onDisappear(perform: { self.action = nil })
                .onAppear(perform: {
                    self.newFileName = ""
                    self.newFileDestination = ""
                    self.newItemText = ""
                })

            }
        }
    }
}

struct BoneItemPickerView: View {
    @State var text: String = ""
    @State var selectedItem: ObjectReference<BoneItem>?
    let items: [ObjectReference<BoneItem>]
    let callback: (ObjectReference<BoneItem>?, String?) -> ()
    var body: some View {
        GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Create", confirm: { self.callback(nil, self.text) }, content:  {
            VStack(spacing: 10) {
                ForEach(items, id:\.self) { item in
                    Text(item.object.name)
                        
                        .onTapGesture { self.callback(item, nil) }
                }
                VStack {
                    Text("or")
                    TextField("create one", text: $text)
                }
            }

        })
    }
}

struct BoneFilesView_Previews: PreviewProvider {
    static var previews: some View {
        BoneFilesView().environmentObject(BoneSpecsController.empty)
    }
}
