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

class BoneSpecsController: ObservableObject {

    struct GroupWithSpec: Hashable, Comparable {
        static func < (lhs: BoneSpecsController.GroupWithSpec, rhs: BoneSpecsController.GroupWithSpec) -> Bool {
            if rhs.spec == lhs.spec {
                return lhs.group < rhs.group
            }
            return lhs.spec < rhs.spec
        }

        static func == (lhs: BoneSpecsController.GroupWithSpec, rhs: BoneSpecsController.GroupWithSpec) -> Bool {
            lhs.spec.object.name == rhs.spec.object.name && lhs.group.name == rhs.group.name
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(spec.object.name)
            hasher.combine(group.name)
        }

        var spec: ObjectReference<BoneSpec>
        var group: BoneGroup

    }

    @Published var showPreview: Bool = true
    @Published var showErrorAlert: Bool = false

    @Published var currentItemController: BoneItemController = BoneItemController()
//        {
        //        willSet { objectWillChange.send() }
//        didSet {
//            //            currentItemCancellables = []
//            currentItemController
//                .objectWillChange
//                .delay(for: .nanoseconds(1), scheduler: RunLoop.main)
//                .sink {[weak self] in self?.objectWillChange.send() }
//                .store(in: &currentItemCancellables)
//
//        }
//    }

    @Published var contextController: ContextController = ContextController()

    @Published var itemManager: ItemsController = ItemsController(controllers: [])
    //        {
    //        willSet { objectWillChange.send() }
    //    }

    @Published var currentItems: [ObjectReference<BoneItem>] = [] {
        didSet {
            self.itemManager = (ItemsController(controllers: currentItems
                .flatMap { item in item.object.paths.compactMap { path in

                    BoneItemController(file: try? item.file.parent?.file(at: path.from),
                                       path: path,
                                       context: contextController)
                    }

            }))
            //            objectWillChange.send()
        }
    }


    @Published var groups: [String: [GroupWithSpec]] = [:]
    @Published var specs: [ObjectReference<BoneSpec>] = []

    let folder: Folder
    var pipeline: BonePipeline?

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
        }
    }

    var currentItemCancellables: [AnyCancellable] = []

    var isEmpty: Bool {
        specs.isEmpty
    }

    static var empty: BoneSpecsController {
        BoneSpecsController()
    }

    private var cancellables: [AnyCancellable] = []

    private init() {
        folder = Folder.temporary
        groups = [:]
        specs = []
        contextController = ContextController()
    }
    func reset() {
        self.pipeline = try? BonePipeline(folder: folder)
        self.specs = []
        self.specs = pipeline?.specs.values.map { $0 }.sorted(by: <) ?? []
        self.groups = specs.reduce([:]) {acc, spec in
            let groups = spec.object.groups.map { GroupWithSpec(spec: spec, group: $0)}.sorted()
            return acc.merging([spec.object.name: groups], uniquingKeysWith: {a,b in b })
        }
        self.objectWillChange.send()
    }
    init?(url: URL) {
        guard
            let folder = try? Folder(path: url.path)
           else { return nil }
        var pipelineAttempt = try? BonePipeline(folder: folder)
        if pipelineAttempt == nil {
            try? MurrayfileScaffoldCommand().fromFolder(folder).execute()
            pipelineAttempt = try? BonePipeline(folder: folder)

        }
        guard let pipeline = pipelineAttempt else { return nil }
        self.pipeline = pipeline
        self.folder = folder
        contextController = ContextController(murrayFile: pipeline.murrayFile)

//        contextController.objectWillChange
//            .delay(for: .microseconds(1), scheduler: RunLoop.main)
//            .sink {[weak self] in
//                self?.currentItemController.objectWillChange.send()
//                self?.objectWillChange.send() }
//            .store(in: &cancellables)
        reset()
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
    func allItems() -> [ObjectReference<BoneItem>] {

        guard
            let group = self.selectedGroup else { return [] }
         let groupItems = Set(self.items(for: group))
        return ((try? group.spec.file.parent?.subfolders.compactMap({ (folder) in
            let item = try folder.decodable(BoneItem.self, at: "BoneItem.json")
            let file = try folder.file(at: "BoneItem.json")
            return try ObjectReference(file: file, object: item)
        })) ?? [])
            .filter { groupItems.contains($0) == false }
    }

    func files(for item: ObjectReference<BoneItem>?) -> [File] {
        item?.object.paths
            .map { $0.from }
            .compactMap { try? item?.file.parent?.file(at: $0) }
            .sorted()
            ?? []
    }
    func resetContext() {
        self.contextController.reset()
    }

    var error: CustomError? {
        didSet {
            showErrorAlert = true
        }
    }


    func run() {
        guard
            let pipeline = self.pipeline,
            let group = self.selectedGroup else { return  }

        let items = self.items(for: group)
        let context = self.contextController.context
        withError {
            try items.forEach { item in

                try pipeline.pluginManager.execute(phase: .beforeItemReplace(item: item, context: context), from: self.folder)

                try item.object.paths.forEach({ (path) in

                    if let file = try? item.file.parent?.file(at: path.from),
                        let controller = self.itemManager.controller(for: file) {
                        try pipeline.transform(path: path, customFileContents: controller.resolved, sourceFolder: folder, with: context)
                    }
                })
                try item.object.replacements.forEach({ replacement in
                    try pipeline.replace(from: replacement, sourceFolder: folder, with: context)
                })

                try pipeline.pluginManager.execute(phase: .afterItemReplace(item: item, context: context), from: self.folder)

            }
            return
        }
    }
}

extension BoneSpecsController {

    func withError(_ closure: () throws -> Void ) {
        do {
            try closure()
        } catch let error {
            self.error = error as? CustomError ?? .generic
        }
    }

    func addGroup(named name: String, to spec: ObjectReference<BoneSpec>) {
        let group = BoneGroup(name: name)
        var obj = spec.object
        obj.add(group: group)
        if let json = obj.toJSON(),
            let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]){
            try? spec.file.write(data)
            self.reset()
        }
    }

    func addItem(_ item: ObjectReference<BoneItem>? = nil, named name: String? = nil, to groupRef: GroupWithSpec) {
        withError {
            var groupRef = groupRef

            if let name = name?.trimmingCharacters(in: .whitespacesAndNewlines), name.isEmpty == false {
                try BoneItemScaffoldCommand(specName: groupRef.spec.object.name, name: name, files: [])
                    .fromFolder(self.folder)
                .execute()
                guard let folder = try groupRef.spec.file.parent?.subfolder(at: name) else { return }
                let item = try folder.decodable(BoneItem.self, at: "BoneItem.json")
                let file = try folder.file(at: "BoneItem.json")
                let ref = try ObjectReference(file: file, object: item)
                self.addItem(ref, named: nil, to: groupRef)

                return
            }

            if let item = item, let folder = groupRef.spec.file.parent {
                var spec = groupRef.spec.object
                spec.groups = spec.groups.map { g in
                    var group = g
                    if group == groupRef.group {
                        group.add(itemPath: item.file.path(relativeTo: folder))
                    }
                    return group
                }
                self.specs = []
                groupRef.spec.object = spec
                try groupRef.spec.save()
                self.reset()
                self.selectedGroup = nil
                self.selectedGroup = groupRef
            }
        }
    }

    func addFile(named name: String, destination: String, to item: ObjectReference<BoneItem>) {
        guard let folder = item.file.parent else { return }
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        var item = item
        let path = BonePath(from: name, to: destination)
        item.object.add(path: path)
        withError {
            try folder.createFile(at: name)
            try item.save()
            let group = self.selectedGroup
            self.selectedGroup = group
        }
    }

    func addSpec(named name: String, folder: String) {
        withError { try
            BoneSpecScaffoldCommand(path: folder, name: name)
                .fromFolder(self.folder)
                .execute()
            self.reset()
        }
    }
}
