//
//  RootSplitViewController.swift
//  addressbook
//

import UIKit
import ContactsUI
import MessageUI
import SwiftUI

final class RootSplitViewController: DoubleColumnSplitViewController {
	weak var coordinator: RootCoordinator?

	// MARK: - Initialization
	init() {
		let sidebarList = UIHostingController(rootView: SidebarList())
		let emptyViewController: UIViewController = {
			let vc = UIViewController()
			vc.view.backgroundColor = .systemGroupedBackground
			vc.navigationController?.setNavigationBarHidden(true, animated: false)
			return vc
		}()

		super.init(primaryViewController: sidebarList, emptyViewController: emptyViewController)
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()

		let sidebarList = primaryNavigation.topViewController as? UIHostingController<SidebarList>
		sidebarList?.rootView.coordinator = coordinator
	}

	// MARK: - UITraitEnvironment
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		view.layoutIfNeeded()
	}

	// MARK: - Key Commands
	override var keyCommands: [UIKeyCommand]? {
		[
			UIKeyCommand(title: L10n.newContact, image: UIImage(systemName: "plus"), action: #selector(performCommand(sender:)), input: "n", modifierFlags: .command),
			UIKeyCommand(title: L10n.searchContacts, image: UIImage(systemName: "magnifyingglass"), action: #selector(performCommand(sender:)), input: "f", modifierFlags: .command),
			UIKeyCommand(title: L10n.SettingsForm.navigationTitle, image: UIImage(systemName: "gear"), action: #selector(performCommand(sender:)), input: ",", modifierFlags: .command),
		]
	}

	@objc func performCommand(sender keyCommand: UIKeyCommand) {
		if keyCommand.input == "n" && keyCommand.modifierFlags == .command {
			coordinator?.createContact()
		} else if keyCommand.input == "f" && keyCommand.modifierFlags == .command {
			coordinator?.searchContacts()
		} else if keyCommand.input == "," && keyCommand.modifierFlags == .command {
			coordinator?.presentSettingsForm()
		}
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}
}

// MARK: - CNContactViewControllerDelegate
extension RootSplitViewController: CNContactViewControllerDelegate {
	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		viewController.dismiss(animated: true)

		guard let contact = contact else { return }

		if let contactListViewController = coordinator?.contactListViewControllerInNavigationController(),
		   case .group(let group) = contactListViewController.viewModel.groupListRow.type {
			contactListViewController.viewModel.add([ContactListRow(contact)], to: group)
		}

		coordinator?.select(ContactListRow(contact))
	}
}

// MARK: - MFMessageComposeViewControllerDelegate
extension RootSplitViewController: MFMessageComposeViewControllerDelegate {
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		controller.dismiss(animated: true)
	}
}

// MARK: - MFMailComposeViewControllerDelegate
extension RootSplitViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}
