//
//  Localizations.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 27/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation

enum Localizations: String {
    case welcomeToMurrayTitle
    case welcomeToMurraySubtitle

    case latestDocuments
    case openExistingProject

    case package
    case procedure
    case item
    case create

    case packagesTitle
    case newPackageTitle
    case clonePackageTitle
    case newPackageDescription
    case clonePackageDescription
    case newPackageFieldTitle
    case newPackageFieldDescription
    case newPackageFieldPath
    case clonePackageFieldPath

    case context

    var translation: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
