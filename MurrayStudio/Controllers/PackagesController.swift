//
//  PackagesController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 28/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import MurrayKit
import Files

typealias Package = ObjectReference<BonePackage>

class WindowHandler: NSObject, NSWindowDelegate {
    let onClose: () -> ()
    init(onClose: @escaping () -> Void = {}) {
        self.onClose = onClose
        super.init()
    }
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}

class PackagesController: ErrorObservableObject {
    @Published var error: CustomError?
    
//    @Binding var selectedPackage: Package
    @Published var packages: [Package] = []
    @Published var currentPackage: Package?
    @Published var currentPackageController: PackageController?
    @Published var contextController: ContextController!
    let windowHandler: WindowHandler
    private var pipeline: BonePipeline?
    private var folder: Folder
    private var cancellables: [AnyCancellable] = []

    var url: URL {
        folder.url
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
        guard let pipeline = pipelineAttempt,
            let file = try? folder.file(at: MurrayFile.fileName),
            let murrayFile = try? ObjectReference(file: file, object: pipeline.murrayFile) else { return nil }
        self.windowHandler = windowHandler
        self.pipeline = pipeline
        self.folder = folder

        contextController = ContextController(murrayFile: Binding(get: {[weak self] in
            self?.reset()
            return try! ObjectReference(file: file, object: self?.pipeline?.murrayFile ?? MurrayFile())
        }, set: {[weak self] _, _ in
            self?.reset()
        }
        ))

        self.$currentPackage
            .map {[weak self] in PackageController(package: $0, context: self?.contextController) }
            .sink { [weak self] in self?.currentPackageController = $0 }
            .store(in: &cancellables)

        reset()
    }
    func reset() {
        self.pipeline = try? BonePipeline(folder: folder)
        self.packages = []
        self.packages = pipeline?.packages.values.map { $0 }.sorted(by: <) ?? []
    }
    func run(procedure: Procedure) {
        guard
            let pipeline = self.pipeline,
            let folder = procedure.package.file.parent else { return  }

        let items = procedure.items()
        let context = self.contextController.context
        withError {
            try items.forEach { item in

                try pipeline.pluginManager.execute(phase: .beforeItemReplace(item: item, context: context), from: self.folder)

                try item.object.paths.forEach({ (path) in

                    if let folder = item.file.parent {
                        try pipeline.transform(path: path, sourceFolder: folder, with: context)
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

extension PackagesController {
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

protocol ErrorObservableObject: ObservableObject {
    var error: CustomError? { get set }
}

extension ErrorObservableObject {
    func withError(_ closure: () throws -> Void ) {
        do {
            try closure()
        } catch let error {
            print(error)
            self.error = error as? CustomError ?? .generic
        }
    }
}
