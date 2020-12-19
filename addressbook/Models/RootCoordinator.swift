//
//  RootCoordinator.swift
//  addressbook
//

import UIKit
import ContactsUI
import MessageUI
import SwiftUI

final class RootCoordinator: NSObject, Coordinator {
	var viewController: RootSplitViewController

	init(viewController: RootSplitViewController) {
		self.viewController = viewController
	}

	func start() {
		if AppSettings.shared.showAllContactsOnAppLaunch {
			select(GroupListRow.allContacts())
		}
	}
}

extension RootCoordinator {
	func select(_ groupListRow: GroupListRow) {
		let vc = ContactListViewController(groupListRow: groupListRow)
		vc.coordinator = self

		viewController.setSecondaryViewController(vc)
	}

	func select(_ contactListRow: ContactListRow) {
		let vc = CNContactViewController(for: contactListRow.contact)
		vc.view.backgroundColor = .systemBackground

		viewController.pushViewControllerInSecondaryNavigation(vc, animated: true)
	}

	func presentSettingsForm() {
		let settingsForm = SettingsForm(dismissAction: { self.viewController.dismiss(animated: true) })

		let vc = UIHostingController(rootView: settingsForm)
		vc.modalPresentationStyle = .pageSheet
		viewController.present(vc, animated: true)
	}

	func presentCallDirectoryEntryList(type: CallDirectoryEntry.EntryType) {
		let vc = UIHostingController(rootView: CallDirectoryEntryList(type: type))

		// Fix navigation title not showing while pushing view controller
		vc.navigationItem.title = vc.rootView.viewModel.navigationTitle
		viewController.setSecondaryViewController(vc)
	}

	func createContact() {
		let vc = CNContactViewController(forNewContact: nil)
		vc.view.backgroundColor = .systemBackground
		vc.delegate = viewController

		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .pageSheet

		viewController.present(nc, animated: true)
	}

	func searchContacts(withSearchText searchText: String? = nil) {
		var contactListViewController = contactListViewControllerInNavigationController()

		if contactListViewController == nil {
			select(.allContacts())
			contactListViewController = contactListViewControllerInNavigationController()
		}

		contactListViewController?.becomeFirstResponderSearchBarOnAppear = true
		contactListViewController?.searchController.searchBar.text = searchText
	}

	func contactListViewControllerInNavigationController() -> ContactListViewController? {
		if viewController.isCollapsed {
			return viewController.primaryNavigation.topViewController as? ContactListViewController
		} else {
			return viewController.secondaryNavigation.topViewController as? ContactListViewController
		}
	}

	func presentErrorAlert(message: String) {
		let alert = UIAlertController(title: L10n.errorAlertTitle, message: message, preferredStyle: .alert)
		alert.addAction(.okAction())
		viewController.present(alert, animated: true)
	}

	func addToGroup(dismissAction: @escaping ((Set<GroupListRow>?) -> Void)) {
		let selectGroupsForm = SelectGroupsForm(dismissHandler: dismissAction)

		let vc = UIHostingController(rootView: selectGroupsForm)
		vc.modalPresentationStyle = .formSheet
		viewController.present(vc, animated: true)
	}

	func editGroups(of contact: CNContact) {
		let editGroupsForm = EditGroupsForm(contactToEditGroups: contact) {
			self.viewController.dismiss(animated: true)
		}

		let vc = UIHostingController(rootView: editGroupsForm)
		vc.modalPresentationStyle = .formSheet
		viewController.present(vc, animated: true)
	}

	func presentEditContactsForm(contacts: [CNContact]) {
		let editContactsForm = EditContactsForm(contacts: contacts) {
			self.viewController.dismiss(animated: true)
		}

		let vc = UIHostingController(rootView: editContactsForm)
		vc.modalPresentationStyle = .pageSheet
		viewController.present(vc, animated: true)
	}

	func call(_ phoneNumberStringValue: String) {
		guard let url = URL(string: "tel:\(phoneNumberStringValue)") else { return }
		UIApplication.shared.open(url, options: [:])
	}

	func sendMessage(to recipients: [String]? = nil, body: String? = nil) {
		guard MFMessageComposeViewController.canSendText() else {
			presentErrorAlert(message: "Cannot send message.")
			return
		}
		
		let vc = MFMessageComposeViewController()
		vc.messageComposeDelegate = viewController
		vc.recipients = recipients
		vc.body = body
		viewController.present(vc, animated: true)
	}

	func sendMail(toRecipients: [String]? = nil, ccRecipients: [String]? = nil, bccRecipients: [String]? = nil, subject: String = "", messageBody: String = "") {
		guard MFMailComposeViewController.canSendMail() else {
			presentErrorAlert(message: "Cannot send mail.")
			return
		}

		let vc = MFMailComposeViewController()
		vc.mailComposeDelegate = viewController
		vc.setToRecipients(toRecipients)
		vc.setCcRecipients(ccRecipients)
		vc.setBccRecipients(bccRecipients)
		vc.setSubject(subject)
		vc.setMessageBody(messageBody, isHTML: false)
		viewController.present(vc, animated: true)
	}

	func presentActivityViewController(activityItems: [Any], applicationActivities: [UIActivity]? = nil, configurePopoverPresentationController: ((UIPopoverPresentationController) -> Void)? = nil ) {
		let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)

		vc.popoverPresentationController?.sourceView = viewController.view
		vc.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
		vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)

		if let popoverPresentationController = vc.popoverPresentationController {
			configurePopoverPresentationController?(popoverPresentationController)
		}

		viewController.present(vc, animated: true)
	}

	func present(_ alertItem: AlertItem) {
		let alert = UIAlertController(title: alertItem.title, message: alertItem.message, preferredStyle: .alert)
		alert.addAction(.okAction())
		viewController.presentedViewController?.present(alert, animated: true)
	}
}
