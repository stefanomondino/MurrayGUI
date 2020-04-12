//
//  MainView.swift
//  MurrayGUI
//
//  Created by Stefano Mondino on 23/01/2020.
//  Copyright © 2020 synesthesia. All rights reserved.
//

import SwiftUI
import AppKit

private extension NSToolbarItem.Identifier {
    static let toggleEditor: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "ToggleEditor")
    
}


extension NSWindow: NSToolbarDelegate {
    func embedding<T: View>(rootView: T) -> NSWindow {

//        let toolbar = NSToolbar()
        self.contentView = NSHostingView(rootView: rootView)
//
//        self.toolbar?.delegate = self as? NSToolbarDelegate
//        toolbar.insertItem(withItemIdentifier: .toggleEditor, at: 0)
//
//        self.toolbar = toolbar
//        self.addTitlebarAccessoryViewController(titlebarAccessory)
        return self
    }
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .toggleEditor:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.title = "Test"
            item.target = self
            let menu = NSMenuItem()
            menu.title = item.title
            item.menuFormRepresentation = menu
            return item
            
        default: return nil
        }
    }
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleEditor]
    }
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleEditor]
    }
}
