//
//  WelcomeView.swift
//  MurrayStudio
//
//  Created by Stefano Mondino on 27/02/2020.
//  Copyright © 2020 Synesthesia. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var controller: WelcomeController

    var body: some View {
        GeometryReader { g in
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    VStack {
                        Image("logo").mask(Circle()).padding()
                        Text(.welcomeToMurrayTitle)
                            .textStyle(TitleStyle())

                    }
                    Spacer()
                    VStack {
                        Button(action: { HistoryController.shared.openFile() }, label: {
                            HStack {
                                Image(nsImageName: NSImage.multipleDocumentsName)
                                Text(.openExistingProject)
                            }
                            }).buttonStyle(BorderlessButtonStyle())
                    }
                    Spacer()
                }

                .frame(width: g.size.width * 0.6, height: g.size.height)
                VStack(alignment: .leading) {

                    List(selection: self.$controller.selection) {
                        Section(header: Text(.latestDocuments)
                            .textStyle(SubtitleStyle())) {
                                    ForEach(self.controller.history, id: \.self) { item in
                                        ItemView(title: item.title, subtitle: item.path, icon: .folder)
                                    }
                        }
                    }
                }
            }
        }.onDisappear(perform: { self.controller.reload()})
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(controller: WelcomeController())
    }
}
