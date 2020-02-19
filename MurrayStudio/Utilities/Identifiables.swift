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

extension ObjectReference: Equatable {
    public static func == (lhs: ObjectReference<T>, rhs: ObjectReference<T>) -> Bool {
        return lhs.file == rhs.file
    }

}

extension ObjectReference: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.file.path)
        if let spec = self.object as? BoneSpec {
            hasher.combine(spec.groups)
        }
    }
}

extension BoneGroup: Hashable {
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
