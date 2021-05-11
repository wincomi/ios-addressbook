//
//  MessageComposeView.swift
//  addressbook
//

import MessageUI
import SwiftUI

struct MessageComposeView: UIViewControllerRepresentable {
	static func canSendText() -> Bool {
		MFMessageComposeViewController.canSendText()
	}

	var recipients: [String]?
	var subject: String = ""
	@Environment(\.presentationMode) var presentation
	@Binding var result: MessageComposeResult?

	func makeUIViewController(context: Context) -> MFMessageComposeViewController {
		let vc = MFMessageComposeViewController()
		vc.messageComposeDelegate = context.coordinator
		vc.recipients = recipients
		vc.subject = subject
		return vc
	}

	func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {

	}

	class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
		@Binding var presentation: PresentationMode
		@Binding var result: MessageComposeResult?

		init(presentation: Binding<PresentationMode>, result: Binding<MessageComposeResult?>) {
			_presentation = presentation
			_result = result
		}

		func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
			$presentation.wrappedValue.dismiss()
			self.result = result
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(presentation: presentation, result: $result)
	}

}
