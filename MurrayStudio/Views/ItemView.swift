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
    let nsImageName: String
    var body: some View {
        HStack {
            Image(nsImageName: nsImageName)
            VStack(alignment: .leading) {
                Text(title).textStyle(SubtitleStyle())
                Text(subtitle).textStyle(ContentStyle())
            }
        }
    }
}
