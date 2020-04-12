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
    @Published var currentProcedureController: ProcedureController?
    var items: [Procedure: [Item]] = [:]
    var cancellables: [AnyCancellable] = []
    init(package: Package) {
        self.package = package
        $selectedProcedure.map {[weak self] in
            guard let p = $0 else { return nil }
            return ProcedureController(procedure: p, items: self?.items[p] ?? [])
        }.assign(to: \.currentProcedureController, on: self)
        .store(in: &cancellables)
    }

    func update(procedures: [Procedure]) {
        self.procedures = procedures
        self.items = procedures
            .reduce([:]) { a, p in
                var acc = a
                acc[p] = self.items(for: p)
                return acc
        }
    }
    func items(for procedure: ProcedureWithPackage?) -> [Item] {
        guard let procedure = procedure else { return []}
        return procedure.items()
    }
    
}

