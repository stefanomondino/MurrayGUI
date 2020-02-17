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
            self.resolved = (try? FileTemplate(fileContents: text, context: BoneContext(["name": "Test"])).render()) ?? "error"

        }
    }
    @Published var resolved: String = ""

    init?(file: File?, spec: ObjectReference<BoneSpec>?) {
        guard let file = file, let spec = spec else { return nil }
        self.file = file
//        self.item = item
        self.spec = spec

        text = (try? TemplateReader(source: file.parent!).string(from: file.name, context: BoneContext([:]))) ?? ""
    }
}
