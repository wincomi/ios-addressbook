//
//  ContactListRowContextMenuConfigurationProvider.swift
//  addressbook
//

import UIKit
import Contacts
import MessageUI

final class ContactListRowContextMenuConfigurationProvider: ContextMenuConfigurationProvider {
	let contactListRow: ContactListRow
	let currentGroup: CNGroup?

	/// callHandler
	/// - parameter contactListRow
	/// - parameter phoneNumberStringValue
	var callHandler: ((ContactListRow, String) -> Void)?

	/// sendMessageHandler
	/// - parameter contactListRow
	/// - parameter phoneNumberStringValue
	var sendMessageHandler: ((ContactListRow, String) -> Void)?

	/// sendMailHandler
	/// - parameter contactListRow
	/// - parameter emailAddress
	var sendMailHandler: ((ContactListRow, String) -> Void)?

	var shareHandler: ((ContactListRow) -> Void)?

	/// applicationShortcutItemSettingHandler
	/// - parameter contactListRow
	/// - parameter applicationShortcutItem
	/// - parameter isApplicationShortcutItemEnabled
	var applicationShortcutItemSettingHandler: ((ContactListRow, ApplicationShortcutItem, Bool) -> Void)?

	var editGroupsHandler: ((ContactListRow) -> Void)?

	var removeFromGroupHandler: ((ContactListRow) -> Void)?

	var deleteHandler: ((ContactListRow) -> Void)?

	// MARK: - Initialization
	init(contactListRow: ContactListRow, currentGroup: CNGroup? = nil) {
		self.contactListRow = contactListRow
		self.currentGroup = currentGroup
	}

	// MARK: - ContextMenuConfigurationProvider
	func menuElement(for type: ContactListRow.ContextMenuItemType) -> UIMenuElement? {
		switch type {
		case .call:
			#if DEBUG
			return callMenuElement()
			#else
			return UIApplication.shared.canOpenURL(URL(string: "tel:")!) ? callMenuElement() : nil
			#endif
		case .sendMessage:
			#if DEBUG
			return sendMessageMenuElement()
			#else
			return MFMessageComposeViewController.canSendText() ? sendMessageMenuElement() : nil
			#endif
		case .sendMail:
			#if DEBUG
			return sendMailMenuElement()
			#else
			return MFMailComposeViewController.canSendMail() ? sendMailMenuElement() : nil
			#endif
		case .share:
			return shareMenuElement()
		case .applicationShortcutItemSetting:
			return applicationShortcutItemSettingMenuElement()
		case .editGroups:
			return editGroupsMenuElement()
		case .removeFromGroup:
			return (currentGroup != nil) ? removeFromGroupMenuElement() : nil
		case .delete:
			return confirmDeleteMenuElemnt()
		}
	}

	let menuOptions: UIMenu.Options = AppSettings.shared.isContactContextMenuDisplayInline ? .displayInline : .init()

	private func callMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.call

		let phoneNumberStringValues = contactListRow.contact.phoneNumbers.map(\.value.stringValue)
		guard !phoneNumberStringValues.isEmpty else { return nil }

		let callActions = phoneNumberStringValues.map { phoneNumberStringValue in
			UIAction(title: phoneNumberStringValue, image: UIImage(systemName: type.imageSystemName)) { _ in
				self.callHandler?(self.contactListRow, phoneNumberStringValue)
			}
		}

		if callActions.count == 1 {
			callActions.first?.title = type.localizedTitle
			return callActions.first
		}

		return UIMenu(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), identifier: nil, options: menuOptions, children: callActions)
	}

	private func sendMessageMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.sendMessage

		let phoneNumberStringValues = contactListRow.contact.phoneNumbers.map(\.value.stringValue)
		guard !phoneNumberStringValues.isEmpty else { return nil }

		let sendMessageActions = phoneNumberStringValues.map { phoneNumberStringValue in
			UIAction(title: phoneNumberStringValue, image: UIImage(systemName: type.imageSystemName)) { _ in
				self.sendMessageHandler?(self.contactListRow, phoneNumberStringValue)
			}
		}

		if sendMessageActions.count == 1 {
			sendMessageActions.first?.title = type.localizedTitle
			return sendMessageActions.first
		}

		return UIMenu(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), identifier: nil, options: menuOptions, children: sendMessageActions)
	}

	private func sendMailMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.sendMail

		let emailAddresses = contactListRow.contact.emailAddresses.map { $0.value as String }
		guard !emailAddresses.isEmpty else { return nil }

		let sendMailActions = emailAddresses.map { emailAddress in
			UIAction(title: emailAddress, image: UIImage(systemName: type.imageSystemName)) { _ in
				self.sendMailHandler?(self.contactListRow, emailAddress)
			}
		}

		if sendMailActions.count == 1 {
			sendMailActions.first?.title = type.localizedTitle
			return sendMailActions.first
		}

		return UIMenu(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), identifier: nil, options: menuOptions, children: sendMailActions)
	}

	private func editGroupsMenuElement() -> UIMenuElement {
		let type = ContextMenuItemType.editGroups
		return UIAction(title: "\(type.localizedTitle)...", image: UIImage(systemName: type.imageSystemName)) { _ in
			self.editGroupsHandler?(self.contactListRow)
		}
	}

	private func shareMenuElement() -> UIMenuElement {
		let type = ContextMenuItemType.share
		return UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName)) { _ in
			self.shareHandler?(self.contactListRow)
		}
	}

	private func applicationShortcutItemSettingMenuElement() -> UIMenuElement {
		let applicationShortcutItem = ApplicationShortcutItem.contact(identifier: contactListRow.contact.identifier)
		if AppSettings.shared.applicationShortcutItems.contains(applicationShortcutItem) {
			return UIAction(title: L10n.ContactListRow.ContextMenuItemType.removeFromApplicationShortcutItems, image: UIImage(systemName: "minus.circle")) { _ in
				self.applicationShortcutItemSettingHandler?(self.contactListRow, applicationShortcutItem, true)
			}
		} else {
			return UIAction(title: L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems, image: UIImage(systemName: "plus.app")) { _ in
				self.applicationShortcutItemSettingHandler?(self.contactListRow, applicationShortcutItem, false)
			}
		}
	}

	private func removeFromGroupMenuElement() -> UIMenuElement {
		let type = ContextMenuItemType.removeFromGroup
		return UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), attributes: .destructive) { _ in
			self.removeFromGroupHandler?(self.contactListRow)
		}
	}

	private func confirmDeleteMenuElemnt() -> UIMenuElement {
		let type = ContextMenuItemType.delete
		let delete = UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), attributes: .destructive) { _ in
			self.deleteHandler?(self.contactListRow)
		}

		return UIMenu(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), options: .destructive, children: [delete])
	}
}
