//
//  SummaryView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 06/03/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var packagesController: PackagesController
    @ObservedObject var controller: ProcedureController
    var body: some View {
        VStack {
            HStack {
                ForEach(self.controller.items, id: \.self) {
                    Text($0.object.name)
                }
            }
            
        }
    }
}
