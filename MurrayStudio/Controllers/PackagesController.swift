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

class PackagesController: ErrorObservableObject {
    @Published var error: CustomError?

//    @Binding var selectedPackage: Package
    @Published var packages: [Package] = []
    @Published var currentPackage: Package?

    private var pipeline: BonePipeline?
    private var folder: Folder

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
//        contextController = ContextController(murrayFile: pipeline.murrayFile)

        reset()
    }
    func reset() {
        self.pipeline = try? BonePipeline(folder: folder)
        self.packages = []
        self.packages = pipeline?.packages.values.map { $0 }.sorted(by: <) ?? []
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
            self.error = error as? CustomError ?? .generic
        }
    }
}
