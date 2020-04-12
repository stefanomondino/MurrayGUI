//
//  GroupActionSheet.swift
//


import SwiftUI

struct GroupActionSheet<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode

//    let icon: NSImage
    let message: String
    let informativeText: String
    let content: Content

    let confirmationTitle: String
    let confirmationAction: () -> Void

    internal init(
                  message: String,
                  informativeText: String,
                  confirmationTitle: String,
                  confirm: @escaping () -> Void,
                  @ViewBuilder content: () -> Content) {

        self.message = message
        self.informativeText = informativeText
        self.content = content()
        self.confirmationTitle = confirmationTitle
        self.confirmationAction = confirm
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {


                VStack(alignment: .leading) {
                    Text(message)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    Text(informativeText)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }

            content

            HStack {
                Button("Cancel", action: self.dismiss)
                Spacer()
                Button(confirmationTitle) {
                    self.confirmationAction()
                    self.dismiss()
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(minWidth: 300, idealWidth: 400)
        .padding(20)
    }

    private func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
