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

class ItemsController: ObservableObject {
    @Published var controllers: [BoneItemController]

    init(controllers: [BoneItemController]) {
        self.controllers = controllers
    }

    func controller(for file: File) -> BoneItemController? {
        controllers.first(where: { $0.file == file })
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
            //            self.currentItemController = BoneItemController(file: selectedFile, spec: self.selectedGroup?.spec, context: contextManager)
            if let file = selectedFile {
                self.currentItemController = itemManager.controller(for: file)!
            }
            self.objectWillChange.send()
            self.currentItemController.objectWillChange.send()

        }
    }

    @Published var currentItems: [ObjectReference<BoneItem>] = [] {
        didSet {
            self.itemManager = ItemsController(controllers: currentItems
                .compactMap { self.files(for: $0) }
                .flatMap { $0 }
                .compactMap { file in BoneItemController(file: file, spec: self.selectedGroup?.spec, context: contextManager) })
            objectWillChange.send()
        }
    }

    var currentItemCancellables: [AnyCancellable] = []
    @ObservedObject var currentItemController: BoneItemController = BoneItemController() {
        willSet { objectWillChange.send() }
        didSet {
//            currentItemCancellables = []
            currentItemController
                .objectWillChange
                .delay(for: .nanoseconds(1), scheduler: RunLoop.main)
                .sink {[weak self] in self?.objectWillChange.send() }
                .store(in: &currentItemCancellables)

        }
    }
    @ObservedObject var contextManager: ContextManager

    @Published var itemManager: ItemsController = ItemsController(controllers: []) {
        willSet { objectWillChange.send() }
    }

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
        contextManager = ContextManager()
    }

    init?(url: URL) {
        guard
            let folder = try? Folder(path: url.path),
            let pipeline = try? BonePipeline(folder: folder) else { return nil }
        self.pipeline = pipeline
        self.folder = folder

        self.specs = pipeline.specs.values.map { $0 }
        self.groups = specs.reduce([:]) {acc, spec in
            let groups = spec.object.groups.map { GroupWithSpec(spec: spec, group: $0)}
            return acc.merging([spec.object.name: groups], uniquingKeysWith: {a,b in b })
        }
        contextManager = ContextManager(murrayFile: pipeline.murrayFile)

        contextManager.objectWillChange
            .sink {[weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)
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
    func resetContext() {
        self.contextManager.reset()
    }
    func run() {
        guard
            let pipeline = self.pipeline,
            let spec = self.selectedGroup?.spec,
            let group = self.selectedGroup,
            let name = self.selectedGroup?.group.name else { return  }

        let items = try self.items(for: group)
        let context = self.contextManager.context
        try? items.forEach { item in

            try pipeline.pluginManager.execute(phase: .beforeItemReplace(item: item, context: context), from: self.folder)

            try item.object.paths.forEach({ (path) in
                try pipeline.transform(path: path, sourceFolder: folder, with: context)
            })
            try item.object.replacements.forEach({ replacement in
                try pipeline.replace(from: replacement, sourceFolder: folder, with: context)
            })

            try pipeline.pluginManager.execute(phase: .afterItemReplace(item: item, context: context), from: self.folder)
        }



        //        try? self.pipeline?.execute(boneName: name, with: contextManager.context.context)
    }
}
