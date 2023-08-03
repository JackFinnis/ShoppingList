//
//  EmailView.swift
//  News
//
//  Created by Jack Finnis on 24/03/2023.
//

import SwiftUI
import MessageUI

struct EmailView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let onDismiss: (MFMailComposeResult) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(subject)
        vc.setToRecipients([recipient])
        return vc
    }

    func updateUIViewController(_ vc: MFMailComposeViewController, context: Context) {}
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: EmailView

        init(_ parent: EmailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ vc: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.onDismiss(result)
            vc.dismiss(animated: true)
        }
    }
}

extension View {
    func emailSheet(recipient: String, subject: String, isPresented: Binding<Bool>) -> some View {
        modifier(EmailModifier(recipient: recipient, subject: subject, isPresented: isPresented))
    }
}

struct EmailModifier: ViewModifier {
    @EnvironmentObject var vm: ViewModel
    @State var showEmailSent = false
    @State var showEmailNotSent = false
    
    let recipient: String
    let subject: String
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                EmailView(recipient: recipient, subject: subject) { result in
                    switch result {
                    case .sent:
                        showEmailSent.toggle()
                    case .failed:
                        showEmailNotSent.toggle()
                    default:
                        break
                    }
                }
                .ignoresSafeArea()
                .accentColor(Color(.link))
            }
            .alert("Email Sent", isPresented: $showEmailSent) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Thank you for your feedback!\nWe'll get back to you as soon as possible.")
            }
            .alert("Email Not Sent", isPresented: $showEmailNotSent) {
                Button("OK", role: .cancel) {}
                Button("Open Settings") {
                    openSettings()
                }
            } message: {
                Text("Please authenticate your email account and try again.")
            }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
