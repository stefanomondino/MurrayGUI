//
//  AppDelegate.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    @UserDefaultsBacked(key: .lastProject) var lastProject: String?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
//        let contentView = MainView()
//
//        // Create the window and set the content view. 
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)

        if let last = lastProject {
            DispatchQueue.main.async {
                self.openMurrayWindow(url: URL(fileURLWithPath: last))
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openFile(_ sender: Any) {
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
//    @IBAction func newFile(_ sender: Any) {
//        let panel = NSOpenPanel()
//        panel.canChooseDirectories = true
//        panel.canChooseFiles = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let result = panel.runModal()
//            if let url = panel.url, result == .OK {
//                self.openMurrayWindow(url: url)
//                //                           self.viewModel.url = url
//            }
//        }
//    }

    func openMurrayWindow(url: URL) {
        guard let controller = BoneSpecsController(url: url) else { return }
        lastProject = url.path
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1600, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
            .embedding(rootView: MainView().environmentObject(controller))
        window.center()
        window.title = controller.folder.path
        window.setFrameAutosaveName("Main Window")
        window.makeKeyAndOrderFront(nil)
    }
}

