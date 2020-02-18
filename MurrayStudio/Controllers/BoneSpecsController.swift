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

class ObservableArray<T>: ObservableObject {

    @Published var array:[T] = [] {
        willSet { objectWillChange.send() }
    }
//    var cancellables = [AnyCancellable]()

    init(array: [T]) {
        self.array = array

    }

//    func observeChildrenChanges<T: ObservableObject>() -> ObservableArray<T> {
//        let array2 = array as! [T]
//        array2.forEach({
//            let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
//
//            // Important: You have to keep the returned value allocated,
//            // otherwise the sink subscription gets cancelled
//            self.cancellables.append(c)
//        })
//        return self as! ObservableArray<T>
//    }


}
struct ContextPair: Identifiable {
    var id: String { key }
    var key: String
    var value: String
}

//class ContextPair: ObservableObject, Hashable, Identifiable {
//    static func == (lhs: ContextPair, rhs: ContextPair) -> Bool {
//        lhs.key == rhs.key && lhs.value.wrappedValue == rhs.value.wrappedValue
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(key)
//        hasher.combine(value.wrappedValue)
//    }
//    var key: String = ""
//    private var innerValue: String = ""
//    var id: String { key }
//
//    var value = Binding<String>(get: {return ""}, set: {_ in })
//
//    init?(key: String, value: Any) {
//        guard let string = value as? CustomStringConvertible else { return nil }
//        self.key = key
//        self.innerValue = string.description
//        self.value = Binding(get: { () -> String in
//            print (self.innerValue)
//            return self.innerValue
//        }, set: {
//            self.innerValue = $0
//            self.objectWillChange.send()
//        })
//
//    }
//}

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
            self.currentItemController = BoneItemController(file: selectedFile, spec: self.selectedGroup?.spec, context: contextManager)
        }
    }

    @Published var currentItems: [ObjectReference<BoneItem>] = []
    @Published var currentItemController: BoneItemController?
    @ObservedObject var contextManager: ObservableArray<ContextPair>

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
        contextManager = ObservableArray(array: [])
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
        contextManager = ObservableArray(array: [ContextPair(key: "name", value: "Test")].compactMap { $0 } +
            pipeline.murrayFile.environment.compactMap { ContextPair(key: $0.key, value: $0.value as! String) })
        
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

    func run() {
        guard let name = self.selectedGroup?.group.name else { return  }
        let context = contextManager.array
            .reduce([String: String]()){ a, t in
                a.merging([t.key: t.value], uniquingKeysWith: {$1})
        }
        try? self.pipeline?.execute(boneName: name, with: context)
    }
}
