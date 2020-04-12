//
//  SummaryView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 06/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit

struct SummaryView: View {
    @EnvironmentObject var packagesController: PackagesController
    @ObservedObject var controller: ProcedureController
    var body: some View {
        VStack {
            List {
                ForEach(self.controller.items, id: \.self) { item in
                    self.sectionView(from: item)
                }
            }
            HStack {
                Button(action: { self.packagesController.run(procedure: self.controller.procedure) }, label: {
                    Text("Execute")
                })
            }
            
        }
    }

    func sectionView(from item: Item) -> some View {
        Section(header: Text(item.object.name)) {
            if item.object.paths.isEmpty == false {
                Text("Files")
                ForEach(item.object.paths, id: \.self) { path in
                    VStack(alignment: .leading) {
                        Text("From: \(path.from)")
                        Text("To: \( (try? path.to.resolved(with: self.packagesController.contextController.context)) ?? "")")
                    }
                }
            }
            if item.object.replacements.isEmpty == false {
                Text("Replacements")
                ForEach(item.object.replacements, id: \.self) { replacement in
                    VStack(alignment: .leading) {
                        Text("From: \( (try? (replacement.text ?? replacement.sourcePath ?? "").resolved(with: self.packagesController.contextController.context)) ?? "")")
                        //                                    Text("Placeholder: \(replacement.placeholder)")
                        Text("To: \( (try? replacement.destinationPath.resolved(with: self.packagesController.contextController.context)) ?? "")")
                    }
                }
            }
        }
    }
}
