//
//  HistoryController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 27/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

struct HistoryItem: Codable, Identifiable, Comparable, Hashable {
    static func < (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.lastOpened < rhs.lastOpened
    }

    var id: URL { url }

    var lastOpened: Date
    let url: URL

    var path: String { url.path }
    var title: String { url.lastPathComponent }
}

class HistoryController: ObservableObject {
    static let shared = HistoryController()

    @CodableUserDefaultsBacked(key: .history) private var historyItems: [HistoryItem]? {
        didSet { objectWillChange.send() }
    }
    @CodableUserDefaultsBacked(key: .lastOpened) private var openedItems: [HistoryItem]? {
        didSet { objectWillChange.send() }
    }

    func history() -> [HistoryItem] {
        return historyItems ?? []
    }
    func lastOpened() -> [HistoryItem] {
        return openedItems ?? []
    }

    func addToHistory(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        let item = HistoryItem(lastOpened: Date(), url: url)
        self.historyItems = ((self.historyItems ?? []).filter { $0.url != item.url } + [item]).sorted(by: >)
    }
    
    func removeFromHistory(_ item: HistoryItem) {
        self.historyItems = (self.historyItems ?? []).filter { $0.url != item.url }
    }
    func addToOpened(_ url: URL) {
        let item = HistoryItem(lastOpened: Date(), url: url)
        self.openedItems = ((self.openedItems ?? []).filter { $0.url != item.url } + [item]).sorted(by: >)
    }

    func removeFromOpened(_ item: HistoryItem) {
        self.openedItems = (self.openedItems ?? []).filter { $0.url != item.url }
    }

    func openLastOrWelcome() {

        let opened = lastOpened()
        if opened.isEmpty {
            openWelcome()
        } else {
            opened.prefix(10).forEach { item in
                openMurrayWindow(url: item.url)
            }
        }
    }

    func openMurrayWindow(url: URL) {
        welcome?.close()
        let handler = WindowHandler {[weak self] in
             self?.removeFromOpened(HistoryItem(lastOpened: Date(), url: url))
            if self?.lastOpened().isEmpty == true {
                self?.openWelcome()
            }
        }
        guard let controller = BonePackagesController(url: url, windowHandler: handler) else { return }
        addToHistory(url)
        addToOpened(url)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1600, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
            .embedding(rootView: MainView().environmentObject(controller))
        //        (NSApplication.shared.delegate as? AppDelegate)?.window = window
        window.center()
        window.title = controller.folder.path
        window.setFrameAutosaveName(controller.folder.path)
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.delegate = controller.windowHandler

    }

    private var welcome: NSWindow?

    func openWelcome() {
        guard let welcome = welcome else {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.closable,.titled, .fullSizeContentView],
            backing: .buffered, defer: false)
            .embedding(rootView: WelcomeView(controller: WelcomeController()))
        
        //        (NSApplication.shared.delegate as? AppDelegate)?.window = window

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        window.isReleasedWhenClosed = false
            self.welcome = window
            openWelcome()
        return
        }
        welcome.center()
        welcome.makeKeyAndOrderFront(nil)
    }


    func openFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = panel.runModal()
            if let url = panel.url, result == .OK {
                self.openMurrayWindow(url: url)
                //                           self.viewModel.url = url
            }
        }
    }
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
            let content = window.contentView as? NSHostingView<MainView> {
            let controller = content.rootView.specsController
            let url = controller.folder.url
            self.removeFromOpened(HistoryItem(lastOpened: Date(), url: url))
        }
    }
}
