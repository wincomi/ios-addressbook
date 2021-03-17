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
		let nc = UIHostingController(rootView: settingsForm)
		nc.modalPresentationStyle = .pageSheet
		viewController.present(nc, animated: true)
	}

	func presentCallDirectoryEntryList(type: CallDirectoryEntry.EntryType) {
		let callDirectoryEntryList = CallDirectoryEntryList(type: type)
		let vc = UIHostingController(rootView: callDirectoryEntryList)

		// To Fix navigation title not showing while pushing view controller
		vc.navigationItem.title = vc.rootView.viewModel.navigationTitle

		viewController.setSecondaryViewController(vc)
	}

	func presentMessageFilterList() {
		let viewModel = MessageFilterListViewModel()
		let messageFilterList = MessageFilterList(viewModel: viewModel)
		let vc = UIHostingController(rootView: messageFilterList)

		vc.navigationItem.title = L10n.MessageFilterList.navigationTitle

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

	func addToGroup(contacts: [CNContact]) {
		let nc = UIHostingController(rootView: addToGroupForm(contacts: contacts))
		nc.modalPresentationStyle = .formSheet
		viewController.present(nc, animated: true)
	}

	func editGroups(of contact: CNContact) {
		let nc = UIHostingController(rootView: editGroupsForm(contact: contact))
		nc.modalPresentationStyle = .formSheet
		viewController.present(nc, animated: true)
	}

	func edit(contacts: [CNContact]) {
		let nc = UIHostingController(rootView: editContactsForm(contacts: contacts))
		nc.modalPresentationStyle = .pageSheet
		viewController.present(nc, animated: true)
	}

	func call(_ phoneNumber: String) {
		guard let url = URL(string: "tel:\(phoneNumber)"),
			  UIApplication.shared.canOpenURL(url) else { return }
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

	func presentErrorAlert(message: String) {
		let alertItem = AlertItem(title: L10n.errorAlertTitle, message: message)
		present(alertItem)
	}

	func contactListViewControllerInNavigationController() -> ContactListViewController? {
		if viewController.isCollapsed {
			return viewController.primaryNavigation.topViewController as? ContactListViewController
		} else {
			return viewController.secondaryNavigation.topViewController as? ContactListViewController
		}
	}
}

private extension RootCoordinator {
	var settingsForm: some View {
		NavigationView {
			SettingsForm {
				self.viewController.dismiss(animated: true)
			}.environmentObject(AppSettings.shared)
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	func editContactsForm(contacts: [CNContact]) -> some View {
		NavigationView {
			EditContactsForm(contacts: contacts) {
				self.viewController.dismiss(animated: true)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	func addToGroupForm(contacts: [CNContact]) -> some View {
		NavigationView {
			AddToGroupForm(contacts: contacts) {
				self.viewController.dismiss(animated: true)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	func editGroupsForm(contact: CNContact) -> some View {
		NavigationView {
			EditGroupsForm(viewModel: .init(contact: contact)) {
				self.viewController.dismiss(animated: true)
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
