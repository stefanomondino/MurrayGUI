//
//  Style.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 27/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .lineSpacing(8)
            .foregroundColor(.primary)
    }
}

struct ContentStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .lineSpacing(4)
            .foregroundColor(.secondary)
    }
}

struct SubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .lineSpacing(4)
            .foregroundColor(.primary)
    }
}

extension Image {
    init(nsImageName: NSImage.Name) {
        self.init(nsImage: NSImage(named: nsImageName) ?? NSImage())
    }
}

extension Text {
    func textStyle<Style: ViewModifier>(_ style: Style) -> some View {
        ModifiedContent(content: self, modifier: style)
    }
    init(_ localization: Localizations) {
        self.init(localization.translation)
    }
}
