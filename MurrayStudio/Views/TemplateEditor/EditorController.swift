//
//  ItemController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 05/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Combine
import MurrayKit
import Files
import SwiftUI

class EditorController: ObservableObject {
    let file: File?
    //    let item: ObjectReference<BoneItem>
    //let spec: ObjectReference<BonePackage>

    private let path: BonePath
    @Published var showPreview: Bool = true
    @Published var source: String = ""
    @Published var destination: String = ""

    @Published var text: String = "" {
        didSet {
            self.resolved = resolve()
        }
    }
    @Published var resolved: String = ""

    @ObservedObject var contextController: ContextController = ContextController()

    private var context: BoneContext = BoneContext([:]) {
        didSet {
            self.resolved = resolve()
            self.source =  (try? path.from.resolved(with: context)) ?? ""
            self.destination = (try? path.to.resolved(with: context)) ?? ""

        }
    }
    private var cancellables: [AnyCancellable] = []
    private func resolve() -> String {
        (try? FileTemplate(fileContents: text, context: contextController.context).render()) ?? "error"
    }
    init() {
        self.file = nil
        self.destination = ""
        self.path = BonePath(from: "", to: "")
    }
    init?(path: Path?, context: ContextController) {
        guard let path = path else { return nil }
        self.file = path.file
        self.path = path.object
        self.contextController = context
        text = (try? TemplateReader(source: path.file.parent!).string(from: path.file.name, context: BoneContext([:]))) ?? ""

        self.contextController.$context
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .assign(to: \.context, on: self)
            .store(in: &cancellables)
    }
    init(file: File?, path: BonePath, context: ContextController) {

        self.file = file
        self.path = path
        self.contextController = context
        guard let file = file else { return }
        text = (try? TemplateReader(source: file.parent!).string(from: file.name, context: BoneContext([:]))) ?? ""

        self.contextController.$context
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .assign(to: \.context, on: self)
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
