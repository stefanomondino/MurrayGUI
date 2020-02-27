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

    let history = HistoryController.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        history.openLastOrWelcome()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openFile(_ sender: Any) {
        history.openFile()
    }

}

