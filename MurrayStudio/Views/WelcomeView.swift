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
                        Image("logo").mask(Circle())
                        Text("Welcome to MurrayStudio")
                            .textStyle(TitleStyle())
                    }
                    Spacer()
                }

                .frame(width: g.size.width * 0.6, height: g.size.height)
                
                    List(selection: self.$controller.selection) {
                        ForEach(self.controller.history, id: \.self) { item in
                            HStack {
                                Image(nsImage: NSImage(named: NSImage.folderName) ?? NSImage())
                                VStack(alignment: .leading) {
                                    Text(item.title).textStyle(SubtitleStyle())
                                    Text(item.path).textStyle(ContentStyle())
                                }
                            }
                        }
                    }.listStyle(PlainListStyle())

            }
        }.onDisappear(perform: { self.controller.reload()})
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(controller: WelcomeController())
    }
}
