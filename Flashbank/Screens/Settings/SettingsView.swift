//
//  SettingsView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 02.10.2024.
//

import SwiftUI
import SettingsIconGenerator

struct SettingsView: View {
    @State private var isVersionToggled: Bool = false
    private func infoCell(
        title1: String,
        title2: String,
        disclosureIndicator: Bool,
        imageName: String,
        imageColor: UIColor,
        didTap: @escaping () -> Void
    ) -> some View {
        ZStack {
            HStack {
                Image(
                    uiImage: .generateSettingsIcon(
                        imageName,
                        backgroundColor: imageColor
                    ) ?? UIImage()
                )
                Text(title1)
                Spacer()
                Text(title2)
                    .foregroundColor(.secondary)
                if disclosureIndicator {
                    Image(systemName: "chevron.forward")
                        .font(Font.system(.caption).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            Button("", action: {
                didTap()
            })
        }
    }
    var body: some View {
        List {
            Section(header: Text("Support")) {
                infoCell(title1: "Ask a question", title2: "Telegram", disclosureIndicator: true, imageName: "bubble.left.fill", imageColor: .orange, didTap: {
                    if let url = URL(string: "https://t.me/Jeytery") {
                        UIApplication.shared.open(url)
                    }
                })
                infoCell(title1: "Ask a question", title2: "Mail", disclosureIndicator: true, imageName: "bubble.left.fill", imageColor: .purple, didTap: {
//                    state.tapItem?(.sendEmailToDeveloper)
//                    if MFMailComposeViewController.canSendMail() {
//                        isShowingMailView = true
//                    }
//                    else {
//                        let email = "dimaostapchenko@gmail.com"
//                        if let url = URL(string: "mailto:\(email)") {
//                            if #available(iOS 10.0, *) {
//                                UIApplication.shared.open(url)
//                            } else {
//                                UIApplication.shared.openURL(url)
//                            }
//                        }
//                    }
                })
            }
            Section {
                infoCell(title1: "Version", title2: isVersionToggled ? "Disco! Disco! Discko!" : "Flashbank 1.0", disclosureIndicator: false, imageName: "1.circle.fill", imageColor: .darkGray, didTap: {
                    isVersionToggled.toggle()
                })
            }
            Section {
                infoCell(title1: "Privacy Policy", title2: "", disclosureIndicator: true, imageName: "doc.text.fill", imageColor: .systemPink, didTap: {
                    if let url = URL(string: "https://github.com/Jeytery/role-cards-docs/blob/main/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                })
            }
            /*
            Section {
                infoCell(title1: "DEGUG BUTTON", title2: "", disclosureIndicator: true, imageName: "circle.lefthalf.filled", imageColor: .systemPink, didTap: {
                    state.tapItem?(.debugButton)
                })
            }
             */
        }
//        .sheet(isPresented: $isShowingMailView) {
//            MailView(isShowing: self.$isShowingMailView, result: self.$result)
//        }
    }
}

#Preview {
    SettingsView()
}
