//
//  ItemsController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 04/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Combine
import MurrayKit
import Files

typealias Item = ObjectReference<BoneItem>
typealias Path = ObjectReference<BonePath>

class ItemsController: ObservableObject {

    let package: ObjectReference<BonePackage>

    @Published var items: [Item] = []

    @Published var selectedFile: Path? 
    @Published var files:[Item: [Path]] = [:]
    @Published var currentFileController: EditorController?

    private var cancellables: [AnyCancellable] = []

    init(package: ObjectReference<BonePackage>, context: ContextController) {
        self.package = package

        $selectedFile
            .map { EditorController(path: $0, context: context) }
            .sink { [weak self] in self?.currentFileController = $0 }
            .store(in: &cancellables)
    }

    func update(items: [Item]) {
        self.items = items
        self.files = items.reduce([:]) { acc, item in
            var a = acc
            a[item] = self.files(for: item)
            return a
        }
    }
    
    private func files(for item:Item?) -> [Path] {
        item?.object.paths
//            .map { $0.from }
            .compactMap { path in
                guard let file = try? item?.file.parent?.file(at: path.from) else { return nil }
                return try? ObjectReference(file: file, object: path)
        }
            .sorted()
            ?? []
    }
}
class ItemController: ObservableObject {

    let package: ObjectReference<BonePackage>

    @Published var items: [Item] = []

    @Published var selectedItem: Item?

    @Published var currentItemController: ItemController?

    init(package: ObjectReference<BonePackage>) {
        self.package = package
    }

    func update(items: [Item]) {
        self.items = items
    }
}
