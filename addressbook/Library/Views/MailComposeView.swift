//
//  MailComposeView.swift
//  addressbook
//

import MessageUI
import SwiftUI

import SwiftUI
import UIKit
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
	static func canSendMail() -> Bool {
		MFMailComposeViewController.canSendMail()
	}

	var subject: String = ""
	var toRecipients: [String]?
	@Environment(\.presentationMode) var presentation
	@Binding var result: Result<MFMailComposeResult, Error>?

	func makeUIViewController(context: UIViewControllerRepresentableContext<MailComposeView>) -> MFMailComposeViewController {
		let vc = MFMailComposeViewController()
		vc.mailComposeDelegate = context.coordinator
		vc.setSubject(subject)
		vc.setToRecipients(toRecipients)
		return vc
	}

	func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailComposeView>) {

	}

	class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
		@Binding var presentation: PresentationMode
		@Binding var result: Result<MFMailComposeResult, Error>?

		init(presentation: Binding<PresentationMode>,
			 result: Binding<Result<MFMailComposeResult, Error>?>) {
			_presentation = presentation
			_result = result
		}

		func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
			defer {
				$presentation.wrappedValue.dismiss()
			}
			guard error == nil else {
				self.result = .failure(error!)
				return
			}
			self.result = .success(result)
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(presentation: presentation, result: $result)
	}
}
