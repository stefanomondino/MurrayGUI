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

class ContextController: ObservableObject {

    @Published var environment:[ContextPair] = []
    @Published var local:[ContextPair] = []

    var cancellables: [AnyCancellable] = []

    func reset() {
        if let murrayFile = murrayFile {
            self.local = [ContextPair(key: murrayFile.mainPlaceholder ?? MurrayFile.defaultPlaceholder, value: "")]
            self.environment = murrayFile.environment.compactMap { ContextPair(key: $0.key, value: $0.value as! String) }
        }
    }
    @Published var context: BoneContext = BoneContext([:])
//        BoneContext(local.dictionary, environment: environment.dictionary)
//    }
    init(environment: [ContextPair] = [], local: [ContextPair] = []) {
        self.murrayFile = nil
        self.environment = environment
        self.local = local
        
    }

    let murrayFile: MurrayFile?

    init(murrayFile: MurrayFile) {
        self.murrayFile = murrayFile

        $environment.combineLatest($local)
            .map { env, local in
                BoneContext(local.dictionary, environment: env.dictionary)
        }
        .assign(to: \.context, on: self)
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
