//
//  ProcedureController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 06/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit
import Combine

class ProcedureController: ObservableObject {
    @Published var items: [Item]
    var procedure: Procedure
    init(procedure: Procedure, items: [Item]) {
        self.items = items
        self.procedure = procedure
    }
}
