//
//  SourceCodeView.swift
//  MurrayGUI
//
//  Created by synesthesia on 24/06/2019.
//  Copyright © 2019 synesthesia. All rights reserved.
//

import Foundation
import Sourceful
import SwiftUI

struct SourceCodeView: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }
    func makeNSView(context: NSViewRepresentableContext<SourceCodeView>) -> SyntaxTextView {
        let view = context.coordinator.view ?? SyntaxTextView(frame: CGRect(x: 0, y: 0, width: 1200, height: 0))
        view.text = text
        view.delegate = context.coordinator
        context.coordinator.view = view
        view.theme = DefaultSourceCodeTheme()
        return view
    }
    func updateNSView(_ nsView: SyntaxTextView, context: NSViewRepresentableContext<SourceCodeView>) {
//        nsView.delegate = context.coordinator
//        nsView.layout()
        if nsView.text != text {
            nsView.text = text
        }
    }

    class Coordinator: NSObject, SyntaxTextViewDelegate {
        var binding: Binding<String>
        weak var view: SyntaxTextView?
        init(binding: Binding<String>) {
            self.binding = binding
        }
        func didChangeText(_ syntaxTextView: SyntaxTextView) {
            binding.wrappedValue = syntaxTextView.text
        }
        func lexerForSource(_ source: String) -> Lexer {
            return SwiftLexer()
        }
    }
}

