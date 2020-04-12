//
//  ProcedureWithPackage.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 12/04/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit

struct ProcedureWithPackage: Hashable, Comparable {
    static func < (lhs: ProcedureWithPackage, rhs: ProcedureWithPackage) -> Bool {
        if rhs.package == lhs.package {
            return lhs.procedure < rhs.procedure
        }
        return lhs.package < rhs.package
    }

    static func == (lhs: ProcedureWithPackage, rhs: ProcedureWithPackage) -> Bool {
        lhs.package.object.name == rhs.package.object.name && lhs.procedure.name == rhs.procedure.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(package.object.name)
        hasher.combine(procedure.name)
    }

    var package: ObjectReference<BonePackage>
    var procedure: BoneProcedure

    func items() -> [Item] {
        return (try? self.procedure
            .itemPaths
            .compactMap { try self.package.file.parent?.file(at: $0) }
            .map { try ObjectReference(file: $0, object: $0.decodable(BoneItem.self))})
            ?? []
    }
}
