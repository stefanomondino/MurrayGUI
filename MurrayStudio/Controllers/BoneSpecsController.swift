//
//  BoneSpecsController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit
import Combine
import Files
import SwiftUI

class ContextPair: Hashable {
    static func == (lhs: ContextPair, rhs: ContextPair) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(value)
    }
    var key: String
    private var value: String = ""
    lazy var currentValue = Binding(get: {
        return self.value
    }, set: { self.value = $0 }
    )
    init?(key: String, value: Any) {
        guard let string = value as? CustomStringConvertible else { return nil }
        self.key = key

        self.value = string.description
    }
}

extension ObjectReference: Equatable {
    public static func == (lhs: ObjectReference<T>, rhs: ObjectReference<T>) -> Bool {
        return lhs.file == rhs.file
    }

}

extension ObjectReference: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.file.path)
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

class BoneSpecsController: ObservableObject {

    struct GroupWithSpec: Hashable {
        static func == (lhs: BoneSpecsController.GroupWithSpec, rhs: BoneSpecsController.GroupWithSpec) -> Bool {
            lhs.spec.object.name == rhs.spec.object.name && lhs.group.name == rhs.group.name
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(spec.object.name)
            hasher.combine(group.name)
        }

        let spec: ObjectReference<BoneSpec>
        let group: BoneGroup

    }

    let folder: Folder
    var pipeline: BonePipeline?
    let groups: [String: [GroupWithSpec]]
    let specs: [ObjectReference<BoneSpec>]
    
    private var cancellables: [AnyCancellable] = []

    @Published var showPreview: Bool = true

    var selectedGroup: GroupWithSpec? {
//        willSet { objectWillChange.send() }
        didSet {
            self.currentItems = items(for: selectedGroup)
            self.selectedFile = nil
        }
    }

    var selectedFile: File? {
        didSet {
            self.currentItemController = BoneItemController(file: selectedFile, spec: self.selectedGroup?.spec)
        }
    }

    @Published var currentItems: [ObjectReference<BoneItem>] = []
    @Published var currentItemController: BoneItemController?
    @Published var contextPairs: [ContextPair] = []

    var isEmpty: Bool {
        specs.isEmpty
    }
    static var empty: BoneSpecsController {
        BoneSpecsController()
    }
    private init() {
        folder = Folder.temporary
        groups = [:]
        specs = []
    }

    init?(url: URL) {
        guard
            let folder = try? Folder(path: url.path),
            let pipeline = try? BonePipeline(folder: folder) else { return nil }
        self.pipeline = pipeline
        self.folder = folder
        self.contextPairs = [ContextPair(key: "name", value: "")].compactMap { $0 } +
            pipeline.murrayFile.environment.compactMap { ContextPair(key: $0.key, value: $0.value) }
        self.specs = pipeline.specs.values.map { $0 }
        self.groups = specs.reduce([:]) {acc, spec in
            let groups = spec.object.groups.map { GroupWithSpec(spec: spec, group: $0)}
            return acc.merging([spec.object.name: groups], uniquingKeysWith: {a,b in b })
        }
    }

    func groups(for spec: ObjectReference<BoneSpec>) -> [GroupWithSpec] {
        groups[spec.object.name] ?? []
    }

    func items(for group: GroupWithSpec?) -> [ObjectReference<BoneItem>] {
        guard let group = group else { return []}
        let spec = group.spec
        return (try? group
            .group
            .itemPaths
            .compactMap { try spec.file.parent?.file(at: $0) }
            .map { try ObjectReference(file: $0, object: $0.decodable(BoneItem.self))})
            ?? []
    }

    func files(for item: ObjectReference<BoneItem>?) -> [File] {
        item?.object.paths
            .map { $0.from }
            .compactMap { try? item?.file.parent?.file(at: $0) }
        ?? []
    }


}
