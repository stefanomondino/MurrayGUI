//
//  ItemView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 28/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI

struct ItemView: View {
    let title: String
    let subtitle: String
    var icon: MaterialDesignIcon?

    init (title: String,
          subtitle: String,
          icon: MaterialDesignIcon? = nil) {
        self.title = title
        self.subtitle = subtitle
//        self.icon = icon
    }
    var body: some View {
        HStack {
            if icon != nil {
                MaterialDesignIconView(icon!, size: 40)
            }
            VStack(alignment: .leading) {
                Text(title).textStyle(SubtitleStyle())
                Text(subtitle).textStyle(ContentStyle())
            }
        }
    }
}
