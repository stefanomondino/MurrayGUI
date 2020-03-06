//
//  PackageView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 28/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit
import Combine

struct PackagesView: View {
    @EnvironmentObject var controller: PackagesController

    @State private var action: Action?

    @State private var newPackageName = ""
    @State private var newPackageDescription = ""
    @State private var newPackagePath = ""
    @State private var clonePackagePath = ""

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if self.controller.packages.isEmpty {
                    Text(.packagesTitle)
                } else {
                    List(selection: self.$controller.currentPackage) {
                        ForEach(self.controller.packages, id: \.self) {
                        PackageItemView(package: $0)
                        }
                    }
                }
                Spacer()
                HStack {
                Button(action: { self.action = .newPackage}) {
                    Text ("New")
                }
                Button(action: { self.action = .clonePackage}) {
                    Text ("Clone")
                }
                }
            }.padding(4)

            Spacer()
        }.sheet(item: self.$action, onDismiss: {
            self.action = nil
        }) { action in
            GroupActionSheet(message: action.title.translation,
                             informativeText: action.description.translation,
                             confirmationTitle: Localizations.create.translation.firstUppercased(),
                             confirm: {
                self.action = nil
                                switch action {
                                case.clonePackage:
                                    self.controller.clone(from: self.clonePackagePath)
                                case .newPackage:
                                    self.controller.addPackage(named: self.newPackageName,
                                                               description: self.newPackageDescription,
                                                               folder: self.newPackagePath)
                                default: break
                                }

            }) {
                if action == .newPackage {
                VStack {
                    TextField(.newPackageFieldTitle, text: self.$newPackageName)
                    TextField(.newPackageFieldDescription, text: self.$newPackageDescription)
                    TextField(.newPackageFieldPath, text: self.$newPackagePath)
                }
                }
                else if action == .clonePackage {
                    VStack {
                        TextField(.clonePackageFieldPath, text: self.$clonePackagePath)
                    }
                }
                else {
                    EmptyView()
                }
            }
        }
    }
}

struct PackageItemView: View {
    let package: ObjectReference<BonePackage>
    var body: some View {
        ItemView(title: package.object.name, subtitle: "\(package.object.procedures.count)", nsImageName: NSImage.folderName)
    }
}

extension PackagesView {
    enum Action: String, Identifiable {
        var id: String { rawValue }

        case newPackage
        case clonePackage

        var title: Localizations {
            switch self {
            case .newPackage: return .newPackageTitle
            case .clonePackage: return .newPackageTitle

            }
        }
        var description: Localizations {
            switch self {
            case .newPackage: return .newPackageDescription
            case .clonePackage: return .newPackageDescription

            }
        }
    }
}
