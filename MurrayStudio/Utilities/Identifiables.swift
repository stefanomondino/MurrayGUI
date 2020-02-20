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
        if let spec = self.object as? BoneSpec {
            hasher.combine(spec.name)
            hasher.combine(spec.groups)
        }
        if let item = self.object as? BoneItem {
            hasher.combine(item.name)
        }
    }

    public static func <(lhs: ObjectReference, rhs: ObjectReference) -> Bool{
        if let l = lhs as? ObjectReference<BoneSpec>, let r = rhs as? ObjectReference<BoneSpec> {
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

extension BoneGroup: Hashable, Comparable {
    public static func < (lhs: BoneGroup, rhs: BoneGroup) -> Bool {
        lhs.name < rhs.name
    }

    public static func == (lhs: BoneGroup, rhs: BoneGroup) -> Bool {
        lhs.name == rhs.name && lhs.itemPaths == rhs.itemPaths
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(itemPaths)
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
