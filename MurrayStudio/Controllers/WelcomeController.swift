//
//  WelcomeController.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 27/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI
import Combine

class WelcomeController: ObservableObject {
    @Published var history: [HistoryItem] = []
    @Published var selection: HistoryItem? {
        didSet {
            if let selection = selection {
                HistoryController.shared.openMurrayWindow(url: selection.url)
                self.selection = nil
            }
        }
    }
    init() {
        reload()
    }
    func reload() {
        self.history = HistoryController.shared.history()
    }
    func openItem(_ item: HistoryItem){
        HistoryController.shared.openMurrayWindow(url: item.url)
    }
}
