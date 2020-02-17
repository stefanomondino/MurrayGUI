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
    @EnvironmentObject var controller: BoneSpecsController

    var body: some View {

        GeometryReader { _ in
            VStack(spacing: 0) {
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
                }
                    ) {
                    ForEach(groups, id: \.self) { group in
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

struct BoneSpecsView_Previews: PreviewProvider {
    static var previews: some View {
        BoneSpecsView().environmentObject(BoneSpecsController.empty)
    }
}
