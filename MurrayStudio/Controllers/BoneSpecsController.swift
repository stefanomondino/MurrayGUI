//
//  BonePackagesController.swift
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


class BonePackagesController: ObservableObject {
    let windowHandler: WindowHandler

    

    @Published var showPreview: Bool = true
    @Published var showErrorAlert: Bool = false

    @Published var currentItemController: BoneItemController = BoneItemController()
    @Published var currentReplacementController = BoneReplacementController()
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
    @Published var replacementManager = ReplacementsController(controllers: [])
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
            self.replacementManager = (ReplacementsController(controllers: currentItems
                           .flatMap { item in item.object.replacements.compactMap { r in
                            BoneReplacementController(file:  try? item.file.parent?.file(at: r.sourcePath ?? ""), replacement: r, context: self.contextController)
                               }

                       }))
            //            objectWillChange.send()
        }
    }


    @Published var groups: [String: [GroupWithSpec]] = [:]
    @Published var packages: [ObjectReference<BonePackage>] = []

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
            if let file = selectedFile {
                selectedReplacement = nil
                self.currentItemController = itemManager.controller(for: file)!
            }
        }
    }

    var selectedReplacement: ObjectReference<BoneReplacement>? {
        didSet {
            if let replacement = selectedReplacement {
                self.selectedFile = nil
                self.currentReplacementController = replacementManager.controller(for: replacement.object)!
            }
        }
    }

    var currentItemCancellables: [AnyCancellable] = []

    var isEmpty: Bool {
        packages.isEmpty
    }

    static var empty: BonePackagesController {
        BonePackagesController()
    }

    private var cancellables: [AnyCancellable] = []

    private init() {
        folder = Folder.temporary
        groups = [:]
        packages = []
        contextController = ContextController()
        windowHandler = WindowHandler()
    }

    func reset() {
        self.pipeline = try? BonePipeline(folder: folder)
        self.packages = []
        self.packages = pipeline?.packages.values.map { $0 }.sorted(by: <) ?? []
        self.groups = packages.reduce([:]) {acc, spec in
            let groups = spec.object.procedures.map { GroupWithSpec(package: spec, group: $0)}.sorted()
            return acc.merging([spec.object.name: groups], uniquingKeysWith: {a,b in b })
        }
        self.objectWillChange.send()
    }

    init?(url: URL, windowHandler: WindowHandler) {
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
        self.windowHandler = windowHandler
        contextController = ContextController(murrayFile: pipeline.murrayFile)

        reset()
    }

    func groups(for spec: ObjectReference<BonePackage>) -> [GroupWithSpec] {
        groups[spec.object.name] ?? []
    }

    func items(for group: GroupWithSpec?) -> [ObjectReference<BoneItem>] {
        guard let group = group else { return []}
        let spec = group.package
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
        return ((try? group.package.file.parent?.subfolders.compactMap({ (folder) in
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
    func replacements(for item: ObjectReference<BoneItem>?) -> [ObjectReference<BoneReplacement>] {
        item?.object.replacements.compactMap { replacement in
            guard let path = replacement.sourcePath,
                let file = try? item?.file.parent?.file(at: path) else { return nil }
            return try? ObjectReference(file: file, object: replacement)
            } ?? []
//            .sorted()
//            ?? []
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

extension BonePackagesController {

    func withError(_ closure: () throws -> Void ) {
        do {
            try closure()
        } catch let error {
            self.error = error as? CustomError ?? .generic
        }
    }

    func addGroup(named name: String, to spec: ObjectReference<BonePackage>) {
        let group = BoneProcedure(name: name)
        var obj = spec.object
        obj.add(procedure: group)
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
                try BoneItemScaffoldCommand(specName: groupRef.package.object.name, name: name, files: [])
                    .fromFolder(self.folder)
                .execute()
                guard let folder = try groupRef.package.file.parent?.subfolder(at: name) else { return }
                let item = try folder.decodable(BoneItem.self, at: "BoneItem.json")
                let file = try folder.file(at: "BoneItem.json")
                let ref = try ObjectReference(file: file, object: item)
                self.addItem(ref, named: nil, to: groupRef)

                return
            }

            if let item = item, let folder = groupRef.package.file.parent {
                var package = groupRef.package.object
                package.procedures = package.procedures.map { g in
                    var group = g
                    if group == groupRef.group {
                        group.add(itemPath: item.file.path(relativeTo: folder))
                    }
                    return group
                }
                self.packages = []
                groupRef.package.object = package
                try groupRef.package.save()
                self.selectedGroup = nil
                self.reset()
                if let spec = self.packages.first(where: { $0.object.name == groupRef.package.object.name }),
                    let group = self.groups(for: spec).first(where: { $0.group.name == groupRef.group.name }) {
                    self.selectedGroup = group
                }

//                self.selectedGroup = groupRef
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

    func addPackage(named name: String, description: String? = nil, folder: String) {
        withError { try
            BonePackageScaffoldCommand(path: folder, name: name, description: description)
                .fromFolder(self.folder)
                .execute()
            self.reset()
        }
    }

    func clone(from url: String) {
        withError {
            try BoneCloneCommand(url: url)
                .fromFolder(self.folder)
                .execute()
        }
    }
}
