//
//  ContextView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 17/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import Foundation
import SwiftUI
import MurrayKit

struct ContextView: View {
    @EnvironmentObject var controller: BoneSpecsController

    var body: some View {

        GeometryReader { _ in
  
            Text("context")
        }
    }
}

struct ContextView_Previews: PreviewProvider {
    static var previews: some View {
        ContextView().environmentObject(BoneSpecsController.empty)
    }
}
