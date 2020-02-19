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

class BoneItemController: ObservableObject {

    let file: File
//    let item: ObjectReference<BoneItem>
    let spec: ObjectReference<BoneSpec>

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
        }
    }
    private var cancellables: [AnyCancellable] = []
    private func resolve() -> String {
        (try? FileTemplate(fileContents: text, context: context).render()) ?? "error"
    }
    init?(file: File?, spec: ObjectReference<BoneSpec>?, context: ContextManager) {
        guard let file = file, let spec = spec else { return nil }
        self.file = file
//        self.item = item
        self.spec = spec

        text = (try? TemplateReader(source: file.parent!).string(from: file.name, context: BoneContext([:]))) ?? ""

        context.objectWillChange
            .delay(for: .nanoseconds(1), scheduler: RunLoop.main)
            .prepend(())
            .map { context.context }
            .sink { [weak self] in self?.context = $0}
    .store(in: &cancellables)
    }
}
