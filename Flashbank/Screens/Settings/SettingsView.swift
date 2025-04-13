//
//  SettingsView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 02.10.2024.
//

import SwiftUI
import SettingsIconGenerator
import MessageUI

struct SettingsView: View {
    
    @State private var isVersionToggled: Bool = false
    @State private var isShowingMailView: Bool = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
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
    
    var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var tableViewWidth: CGFloat {
        return min(UIScreen.main.bounds.width / 2, 600)
    }
    
    var body: some View {
        if isIPhone {
            List {
                listContent()
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$result)
            }
        } else {
            List {
                listContent()
            }
            .frame(width: tableViewWidth)
            .sheet(isPresented: $isShowingMailView) {
                MailView(isShowing: self.$isShowingMailView, result: self.$result)
            }
        }
    }
    
    @ViewBuilder private func listContent() -> some View {
        Section {
            infoCell(title1: "Version", title2: isVersionToggled ? "Disco! Disco! Disco!" : "PartyColors 1.1", disclosureIndicator: false, imageName: "1.circle.fill", imageColor: .darkGray, didTap: {
                isVersionToggled.toggle()
            })
        }
        Section(header: Text("Support")) {
            infoCell(title1: "Ask a question", title2: "Telegram", disclosureIndicator: true, imageName: "bubble.left.fill", imageColor: .systemPink, didTap: {
                if let url = URL(string: "https://t.me/Jeytery") {
                    UIApplication.shared.open(url)
                }
            })
            infoCell(title1: "Ask a question", title2: "Mail", disclosureIndicator: true, imageName: "bubble.left.fill", imageColor: .systemOrange, didTap: {
                if MFMailComposeViewController.canSendMail() {
                    isShowingMailView = true
                }
                else {
                    let email = "dimaostapchenko@gmail.com"
                    if let url = URL(string: "mailto:\(email)") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
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
}

#Preview {
    SettingsView()
}


fileprivate struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(isShowing: Binding<Bool>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["dimaostapchenko@gmail.com"])
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
