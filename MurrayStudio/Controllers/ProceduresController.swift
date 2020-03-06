//
//  ProceduresController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 04/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import MurrayKit
import Combine

typealias Procedure = ProcedureWithPackage

class ProceduresController: ObservableObject {

    let package: Package

    @Published var procedures: [Procedure] = []
    @Published var selectedProcedure: Procedure?
    
    init(package: Package) {
        self.package = package
    }
    func update(procedures: [Procedure]) {
        self.procedures = procedures
    }
}
