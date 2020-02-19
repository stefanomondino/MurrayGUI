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

struct BoneSpecsView: View {

    enum Action: Int, Identifiable {
        case rename
        case new
        case delete

        var id: Int { rawValue }

        var sheetTitle: String {
            switch self {
            case .rename: return "Rename Group"
            case .new: return "New Group"
            case .delete: return "Delete Group"
            }
        }

        var saveActionTitle: String {
            switch self {
            case .rename: return "Rename"
            case .new: return "New"
            case .delete: return "Delete"
            }
        }
    }

    @EnvironmentObject var controller: BoneSpecsController
    @State var filterString: String = ""
    @State var action: Action?
    @State var newGroupName = ""

    var body: some View {

        GeometryReader { _ in
            VStack(alignment: .leading, spacing: 0) {
                List(selection: self.$controller.selectedGroup) {
                    if self.controller.isEmpty {
                        Text("No specs found in current project")
                    } else {
                        ForEach(self.controller.specs, id:\.self) { spec in
                            self.section(for: spec)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                Spacer()
                HStack {

                    Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                        .controlSize(.regular)
                        .onTapGesture { print("!") }
                    TextField("Filter", text: self.$filterString)

                }.padding(4)
                Spacer()
            }
        }
    }

    private func section(for spec: ObjectReference<BoneSpec>) -> some View {
        let groups = controller.groups(for: spec)
        return Group {
            if groups.isEmpty {
                EmptyView()
            } else {
                Section(header:
                    HStack(spacing: 2)  {
                        Text(spec.object.name.uppercased())
                        Text("(\(spec.object.groups.count))")
                        Spacer()
                        Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                            .controlSize(.regular)
                            .onTapGesture { self.action = .new }
                    }
//                    .contextMenu(ContextMenu {
//                        Button("Add group...") { self.action = .new }
//                    })
                        .sheet(item: self.$action) { action in
                            if action == .new {
                                GroupActionSheet(message: "test", informativeText: "test", confirmationTitle: "Test", confirm: {
                                    self.controller.addGroup(named: self.newGroupName, to: spec)
                                }, content: { TextField("Group name", text: self.$newGroupName) })
                            } else {
                                EmptyView()
                            }


                    }
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
}

extension BoneGroup {
    func contains(_ string: String) -> Bool {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty { return true }
        return name.lowercased().contains(string.lowercased())
    }
}

struct BoneSpecsView_Previews: PreviewProvider {
    static var previews: some View {
        BoneSpecsView().environmentObject(BoneSpecsController.empty)
    }
}
