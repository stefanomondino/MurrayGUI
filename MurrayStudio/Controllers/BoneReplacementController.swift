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

class ReplacementsController: ObservableObject {
    @Published var controllers: [BoneReplacementController]

    init(controllers: [BoneReplacementController]) {
        self.controllers = controllers
    }

    func controller(for replacement: BoneReplacement) -> BoneReplacementController? {
        controllers.first(where: { $0.replacement == replacement })
    }
}


class BoneReplacementController: ObservableObject, Identifiable {

    let file: File?

    fileprivate let replacement: BoneReplacement

    @Published var placeholder: String = ""
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
            self.destination = (try? replacement.destinationPath.resolved(with: context)) ?? ""

        }
    }
    private var cancellables: [AnyCancellable] = []
    private func resolve() -> String {
        (try? FileTemplate(fileContents: text, context: contextController.context).render()) ?? "error"
    }
    init() {
        self.file = nil
        self.destination = ""
        self.replacement = BoneReplacement(placeholder: "", text: "", destinationPath: "")
    }

    init(file: File?, replacement: BoneReplacement, context: ContextController) {

        self.file = file
        self.placeholder = replacement.placeholder
        self.replacement = replacement
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
