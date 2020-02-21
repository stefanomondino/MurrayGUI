//
//  BoneItemController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Combine
import MurrayKit
import SwiftUI
import Files

class ItemsController: ObservableObject {
    @Published var controllers: [BoneItemController]

    init(controllers: [BoneItemController]) {
        self.controllers = controllers
    }

    func controller(for file: File) -> BoneItemController? {
        controllers.first(where: { $0.file == file })
    }
}


class BoneItemController: ObservableObject, Identifiable {
//    static func == (lhs: BoneItemController, rhs: BoneItemController) -> Bool {
//        lhs.id == rhs.id && lhs.text == rhs.text && lhs.resolved == rhs.resolved
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(text)
//        hasher.combine(resolved)
//    }

    let file: File?
    //    let item: ObjectReference<BoneItem>
    //let spec: ObjectReference<BoneSpec>

    private let path: BonePath

    @Published var source: String = ""
    @Published var destination: String = ""

    @Published var text: String = "" {
        didSet {
            self.resolved = resolve()
        }
    }
    @Published var resolved: String = "" {
        willSet { objectWillChange.send() }
    }

    private var context: BoneContext = BoneContext([:]) {
        didSet {
            self.resolved = resolve()
            self.source =  (try? path.from.resolved(with: context)) ?? ""
            self.destination = (try? path.to.resolved(with: context)) ?? ""

        }
    }
    private var cancellables: [AnyCancellable] = []
    private func resolve() -> String {
        (try? FileTemplate(fileContents: text, context: context).render()) ?? "error"
    }
    init() {
        self.file = nil
        self.destination = ""
        self.path = BonePath(from: "", to: "")
        context = BoneContext([:])
    }
    init(file: File?, path: BonePath, context: ContextManager) {

        self.file = file
        self.path = path
        guard let file = file else { return }
        text = (try? TemplateReader(source: file.parent!).string(from: file.name, context: BoneContext([:]))) ?? ""

        context.objectWillChange
            .delay(for: .milliseconds(1), scheduler: RunLoop.main)
            .prepend(())
            .map { context.context }
            .sink { [weak self] in self?.context = $0}
            .store(in: &cancellables)
    }
    func restore() {
        guard let file = file else { return }
        text = (try? TemplateReader(source: file.parent!).string(from: file.name, context: BoneContext([:]))) ?? ""
    }
    func save() {
        try? file?.write(self.text)
    }
}
