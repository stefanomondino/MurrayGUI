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

class ContextManager: ObservableObject {

    @Published var environment:[ContextPair] = [] {
        willSet { objectWillChange.send() }
    }
    @Published var local:[ContextPair] = [] {
        willSet { objectWillChange.send() }
    }
    func reset() {
        if let murrayFile = murrayFile {
            self.local = [ContextPair(key: murrayFile.mainPlaceholder ?? MurrayFile.defaultPlaceholder, value: "")]
            self.environment = murrayFile.environment.compactMap { ContextPair(key: $0.key, value: $0.value as! String) }
        }
    }
    var context: BoneContext {
        BoneContext(local.dictionary, environment: environment.dictionary)
    }
    init(environment: [ContextPair] = [], local: [ContextPair] = []) {
        self.murrayFile = nil
        self.environment = environment
        self.local = local
    }

    let murrayFile: MurrayFile?

    init(murrayFile: MurrayFile) {
        self.murrayFile = murrayFile
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
