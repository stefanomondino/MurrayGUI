//
//  Identifiables.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 19/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit
import SwiftUI
import Files

extension ObjectReference: Equatable, Comparable {
    public static func == (lhs: ObjectReference<T>, rhs: ObjectReference<T>) -> Bool {
        return lhs.file == rhs.file
    }

}

extension ObjectReference: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.file.path)
        if let spec = self.object as? BonePackage {
            hasher.combine(spec.name)
            hasher.combine(spec.procedures)
        }
        if let replacement = self.object as? BoneReplacement {
            hasher.combine(replacement.placeholder)
            hasher.combine(replacement.destinationPath)
            hasher.combine(replacement.sourcePath)
            hasher.combine(replacement.text)
        }
        if let item = self.object as? BoneItem {
            hasher.combine(item.name)
        }
    }

    public static func <(lhs: ObjectReference, rhs: ObjectReference) -> Bool{
        if let l = lhs as? ObjectReference<BoneProcedure>, let r = rhs as? ObjectReference<BonePackage> {
            return l.object.name < r.object.name
        }
        if let l = lhs as? ObjectReference<BoneItem>, let r = rhs as? ObjectReference<BoneItem> {
            return l.object.name < r.object.name
        }
        return lhs.file < rhs.file
    }
}
extension File: Comparable {
    public static func < (lhs: File, rhs: File) -> Bool {
        lhs.path < rhs.path
    }


}

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

}

extension BoneProcedure: Hashable, Comparable {
    public static func < (lhs: BoneProcedure, rhs: BoneProcedure) -> Bool {
        lhs.name < rhs.name
    }

    public static func == (lhs: BoneProcedure, rhs: BoneProcedure) -> Bool {
        lhs.name == rhs.name && lhs.itemPaths == rhs.itemPaths
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(itemPaths)
    }
}

extension BoneReplacement: Hashable, Comparable {
    public static func < (lhs: BoneReplacement, rhs: BoneReplacement) -> Bool {
        lhs.placeholder < rhs.placeholder
    }

    public static func == (lhs: BoneReplacement, rhs: BoneReplacement) -> Bool {
        lhs.placeholder == rhs.placeholder && lhs.destinationPath == rhs.destinationPath && lhs.text == rhs.text && lhs.sourcePath == rhs.sourcePath
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(placeholder)
        hasher.combine(destinationPath)
        hasher.combine(sourcePath)
        hasher.combine(text)
    }
}


extension File: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension BonePath: Hashable, Equatable {
    public static func == (lhs: BonePath, rhs: BonePath) -> Bool {
        lhs.from == rhs.from && lhs.to == rhs.to
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
}
