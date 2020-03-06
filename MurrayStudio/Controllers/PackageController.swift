//
//  PackageController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 04/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import MurrayKit
import Files

class PackageController: ObservableObject {

    var package: Package
    
    @Published var itemsController: ItemsController
    @Published var proceduresController: ProceduresController
    private var procedures: [ProcedureWithPackage]

    init?(package: Package?, context: ContextController?) {
        guard let package = package,
            let context = context else { return nil }
        self.package = package
        self.procedures = package.object.procedures.map {
            ProcedureWithPackage(package: package, procedure: $0)
        }
        self.itemsController = ItemsController(package: package, context: context)
        self.proceduresController = ProceduresController(package: package)
        self.itemsController.update(items: allItems())
        self.proceduresController.update(procedures: procedures)
    }
    
    func items(for group: ProcedureWithPackage?) -> [ObjectReference<BoneItem>] {
        guard let group = group else { return []}
        let spec = group.package
        return (try? group
            .procedure
            .itemPaths
            .compactMap { try spec.file.parent?.file(at: $0) }
            .map { try ObjectReference(file: $0, object: $0.decodable(BoneItem.self))})
            ?? []
    }

    func allItems() -> [ObjectReference<BoneItem>] {
        return Array(Set(procedures.flatMap { procedure -> [ObjectReference<BoneItem>] in
        return ((try? procedure.package.file.parent?.subfolders.compactMap({ (folder) in
            let item = try folder.decodable(BoneItem.self, at: "BoneItem.json")
            let file = try folder.file(at: "BoneItem.json")
            return try ObjectReference(file: file, object: item)
        })) ?? [])
//            .filter { groupItems.contains($0) == false }
            }))
    }
}
