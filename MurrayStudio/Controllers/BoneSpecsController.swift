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

    @Published var showPreview: Bool = true
    @Published var showErrorAlert: Bool = false

    @ObservedObject var currentItemController: BoneItemController = BoneItemController() {
//        willSet { objectWillChange.send() }
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
                                       context: contextManager)
                    }

            }))
//            objectWillChange.send()
        }
    }

    let folder: Folder
    var pipeline: BonePipeline?
    @Published var groups: [String: [GroupWithSpec]] = [:]
    @Published var specs: [ObjectReference<BoneSpec>] = []

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
//            self.objectWillChange.send()
            self.currentItemController.objectWillChange.send()

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
        contextManager = ContextManager()
    }
    func reset() {
        self.pipeline = try? BonePipeline(folder: folder)
        self.specs = pipeline?.specs.values.map { $0 } ?? []
        self.groups = specs.reduce([:]) {acc, spec in
            let groups = spec.object.groups.map { GroupWithSpec(spec: spec, group: $0)}
            return acc.merging([spec.object.name: groups], uniquingKeysWith: {a,b in b })
        }
        self.objectWillChange.send()
    }
    init?(url: URL) {
        guard
            let folder = try? Folder(path: url.path),
            let pipeline = try? BonePipeline(folder: folder) else { return nil }
        self.pipeline = pipeline
        self.folder = folder
        contextManager = ContextManager(murrayFile: pipeline.murrayFile)

        contextManager.objectWillChange
            .delay(for: .microseconds(1), scheduler: RunLoop.main)
            .sink {[weak self] in
                self?.currentItemController.objectWillChange.send()
                self?.objectWillChange.send() }
            .store(in: &cancellables)
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

    func files(for item: ObjectReference<BoneItem>?) -> [File] {
        item?.object.paths
            .map { $0.from }
            .compactMap { try? item?.file.parent?.file(at: $0) }
            ?? []
    }
    func resetContext() {
        self.contextManager.reset()
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
        let context = self.contextManager.context
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

    func addFile(named: String, destination: String, to item: ObjectReference<BoneItem>) {
        guard let folder = item.file.parent else { return }
        var item = item
        let path = BonePath(from: named, to: destination)
        item.object.add(path: path)
        withError {
            try folder.createFile(at: named)
            try item.save()
            let group = self.selectedGroup
            self.selectedGroup = group
        }


    }
}
