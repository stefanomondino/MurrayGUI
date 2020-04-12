//
//  File+Comparable.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 12/04/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import Files

extension File: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

extension File: Comparable {
    public static func < (lhs: File, rhs: File) -> Bool {
        lhs.path < rhs.path
    }
}
