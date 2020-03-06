//
//  ContextManager.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 19/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Combine
import MurrayKit
import SwiftUI
import Gloss

class ContextController: ObservableObject {

    @Published var environment:[ContextPair] = []
    @Published var local:[ContextPair] = []
    @Published var environmentString: String = ""
    @Published var environmentEditor: JSONEditorController!
    var cancellables: [AnyCancellable] = []

    func reset() {
        if let murrayFile = murrayFile {
            self.local = [ContextPair(key: murrayFile.mainPlaceholder ?? MurrayFile.defaultPlaceholder, value: "")]
//            self.environment = murrayFile.environment.compactMap { ContextPair(key: $0.key, value: $0.value as! String) }
        }
    }
    @Published var context: BoneContext = BoneContext([:])
//        BoneContext(local.dictionary, environment: environment.dictionary)
//    }
    init(environment: [ContextPair] = [], local: [ContextPair] = []) {
        self.murrayFile = nil
        self.environment = environment
        self.local = local
        let envBinding = Binding<String>(get: { "" }, set: { _, _ in })
        self.environmentEditor = JSONEditorController(envBinding)
    }

    @Published var murrayFile: MurrayFile?

    init(murrayFile: Binding<ObjectReference<MurrayFile>>) {
        self.murrayFile = murrayFile.wrappedValue.object
        let envBinding = Binding<String>(get: {
            return String(data: (try? JSONSerialization.data(withJSONObject: murrayFile.wrappedValue.object.environment, options: .prettyPrinted)) ?? Data(), encoding: .utf8) ?? ""
            }, set: {[weak self] string, _ in
                if let data = string.data(using: .utf8),
                    let environment = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                    var mf = murrayFile.wrappedValue.object
                    mf.update(environment: environment)
                    if let newReference = try? ObjectReference(file: murrayFile.wrappedValue.file, object: mf) {
                        try? newReference.save()
                        murrayFile.wrappedValue = newReference
                        self?.murrayFile = mf
                        self?.reset()
//                        self?.murrayFile = newReference.object
                    }
//                    murrayFile.object.environment = environment
                }
        })

        self.environmentEditor = JSONEditorController(envBinding)
        $murrayFile.combineLatest($local)
            .map { murrayFile, local in
                BoneContext(local.dictionary, environment: murrayFile?.environment ?? [:] )
        }

        .sink { [weak self] in self?.context = $0 }
        .store(in: &cancellables)

        reset()


    }
}

extension Array where Element == ContextPair {
    var dictionary: [String: String] {
        return reduce([:]) {
            $0.merging([$1.key: $1.value]) { $1 }
        }
    }
}

struct ContextPair: Identifiable, Hashable {
    var id: String { key }
    var key: String
    var value: String
}
