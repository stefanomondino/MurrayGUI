//
//  BonePackagesView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit

struct BonePackagesView: View {

    enum Action: Identifiable {
        case rename
        case newSpec
        case new(ObjectReference<BonePackage>)
        case delete

        var id: String {
            switch self {
            case .newSpec: return "newSpec"
            case .rename: return "rename"
            case .delete: return "delete"
            case .new(let i): return "new_\(i.object)"
            }
        }
        var isNewSpec: Bool {
            switch self {
            case .newSpec: return true
            default: return false
            }
        }
        var newItem: ObjectReference<BonePackage>? {
            switch self {
            case .new(let o): return o
            default: return nil
            }
        }

        var title: String {
            switch self {
            case .newSpec: return "New Bone Spec"
            case .new: return "New Bone Group"
            default: return ""
            }
        }

        var message: String {
            switch self {
            case .newSpec: return "Creates a new Bone Spec, containing groups of items."
            case .new(let spec): return "Creates a new Bone Group in \(spec.object.name). Group0"
            default: return "2"
            }
        }
    }

    @EnvironmentObject var controller: BonePackagesController
    @State var filterString: String = ""
    @State var action: Action?
    @State var newGroupName = ""
    @State var newSpecName = ""
    @State var newSpecPath = ""

    var body: some View {

        GeometryReader { g in
            VStack(alignment: .leading, spacing: 0) {
                Text("Bone Specs")
                List(selection: self.$controller.selectedGroup) {
                    if self.controller.isEmpty {
                        Text("No specs found in current project")
                    } else {
                        ForEach(self.controller.packages.sorted(), id:\.self) { spec in
                            self.section(for: spec)
                        }
                    }
                }
//                .listStyle(SidebarListStyle())
                Spacer()
                HStack {
                    ControlButton(action: { self.action = .newSpec }, icon: NSImage.addTemplateName)
                    TextField("Filter", text: self.$filterString)

                }.padding(4)
                Spacer()
            }.sheet(item: self.$action) { action in
                if action.newItem != nil {
                    GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Test", confirm: {
                        self.action = nil
                        self.controller.addGroup(named: self.newGroupName, to: action.newItem!)
                    }, content: { TextField("Group name", text: self.$newGroupName) })
                }
                else if action.isNewSpec {
                    GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Test", confirm: {
                        self.action = nil
                        self.controller.addPackage(named: self.newSpecName, folder: self.newSpecPath)
                    }, content: { VStack {
                        TextField("Spec name", text: self.$newSpecName)
                        TextField("Path", text: self.$newSpecPath)
                        }
                    })
                }
                else {
                    EmptyView()
                }


            }

            .onAppear(perform: {
                self.newSpecPath = ""
                self.newSpecName = ""
                self.newGroupName = ""
            }).onDisappear(perform: { self.action = nil })
        }
    }

    private func section(for spec: ObjectReference<BonePackage>) -> some View {
        let groups = controller.groups(for: spec)
        return Group {

                Section(header:
                    HStack(spacing: 2)  {
                        Text(spec.object.name.uppercased())
                        Text("(\(spec.object.procedures.count))")
                        Spacer()
                        ControlButton(action: { self.action = .new(spec) }, icon: NSImage.addTemplateName)
                    }
//                    .contextMenu(ContextMenu {
//                        Button("Add group...") { self.action = .new }
//                    })

                ) {
                    ForEach(groups.filter { $0.group.contains(self.filterString) }, id: \.self) { group in
                        HStack {
                            Text(group.group.name)
                            Text("(\(self.controller.items(for: group).count))")
                            Spacer()
                        }
                        .tag(group.group.name)
                    }
                }
        }
    }
}

extension BoneProcedure {
    func contains(_ string: String) -> Bool {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty { return true }
        return name.lowercased().contains(string.lowercased())
    }
}

struct BonePackagesView_Previews: PreviewProvider {
    static var previews: some View {
        BonePackagesView().environmentObject(BonePackagesController.empty)
    }
}
