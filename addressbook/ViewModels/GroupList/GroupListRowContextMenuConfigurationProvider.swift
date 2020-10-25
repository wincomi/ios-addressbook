//
//  GroupListRowContextMenuConfigurationProvider.swift
//  addressbook
//

import UIKit
import Contacts
import MessageUI

final class GroupListRowContextMenuConfigurationProvider: ContextMenuConfigurationProvider {
	let groupListRow: GroupListRow

	var sendMessageHandler: ((GroupListRow, [String]) -> Void)?
	var sendMailHandler: ((GroupListRow, [String]) -> Void)?
	var shareHandler: ((GroupListRow) -> Void)?
	var renameHandler: ((CNGroup) -> Void)?

	/// applicationShortcutItemSettingHandler
	/// - parameter group
	/// - parameter applicationShortcutItem
	/// - parameter isApplicationShortcutItemEnabled
	var applicationShortcutItemSettingHandler: ((CNGroup, ApplicationShortcutItem, Bool) -> Void)?
	var deleteHandler: ((CNGroup) -> Void)?

	// MARK: - Initialization
	init(groupListRow: GroupListRow) {
		self.groupListRow = groupListRow
	}

	// MARK: - ContextMenuConfigurationProvider
	func contextMenuConfiguration() -> UIContextMenuConfiguration {
		UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			UIMenu(title: "", image: nil, identifier: nil, children: [
				UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [
					self.menuElement(for: .sendMessage),
					self.menuElement(for: .sendMail),
				].compactMap { $0 }),
				self.menuElement(for: .share),
				self.menuElement(for: .rename),
				self.menuElement(for: .applicationShortcutItemSetting),
				self.menuElement(for: .delete)
			].compactMap { $0 })
		}
	}

	func menuElement(for type: GroupListRow.ContextMenuItemType) -> UIMenuElement? {
		switch type {
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
		case .rename:
			return renameMenuElement()
		case .applicationShortcutItemSetting:
			return applicationshortcutItemSettingMenuElement()
		case .delete:
			return confirmDeleteMenuElement()
		}
	}

	private func sendMessageMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.sendMessage

		guard let contacts = try? groupListRow.fetchContacts() else { return nil }

		let phoneNumbers = contacts.map(\.phoneNumbers)
		if phoneNumbers.isEmpty { return nil }

		let phoneNumberStringValues = phoneNumbers.reduce([]) { $0 + $1.map(\.value.stringValue) }

		return UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName)) { _ in
			self.sendMessageHandler?(self.groupListRow, phoneNumberStringValues)
		}
	}

	private func sendMailMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.sendMail

		guard let contacts = try? groupListRow.fetchContacts() else { return nil }

		let emailAddress = contacts.map(\.emailAddresses)
		if emailAddress.isEmpty { return nil }

		let emailAddressValues = emailAddress.reduce([]) { $0 + $1.map { $0.value as String } }

		return UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName)) { _ in
			self.sendMailHandler?(self.groupListRow, emailAddressValues)
		}
	}

	private func shareMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.share

		let action = UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName)) { _ in
			self.shareHandler?(self.groupListRow)
		}

		let contacts = (try? groupListRow.fetchContacts()) ?? []
		if contacts.isEmpty {
			action.attributes = .disabled
		}

		return action
	}

	private func renameMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.rename

		guard case .group(let group) = groupListRow.type else { return nil }

		return UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName)) { _ in
			self.renameHandler?(group)
		}
	}

	private func applicationshortcutItemSettingMenuElement() -> UIMenuElement? {
		guard case .group(let group) = groupListRow.type else { return nil }

		let applicationShortcutItem = ApplicationShortcutItem.group(identifier: group.identifier)

		if AppSettings.shared.applicationShortcutItems.contains(applicationShortcutItem) {
			return UIAction(title: L10n.ContactListRow.ContextMenuItemType.removeFromApplicationShortcutItems, image: UIImage(systemName: "minus.square")) { _ in
				self.applicationShortcutItemSettingHandler?(group, applicationShortcutItem, true)
			}
		} else {
			return UIAction(title: L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems, image: UIImage(systemName: "plus.app")) { _ in
				self.applicationShortcutItemSettingHandler?(group, applicationShortcutItem, false)
			}
		}
	}

	private func confirmDeleteMenuElement() -> UIMenuElement? {
		let type = ContextMenuItemType.delete

		guard case .group(let group) = groupListRow.type else { return nil }

		let action = UIAction(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), attributes: .destructive) { _ in
			self.deleteHandler?(group)
		}

		return UIMenu(title: type.localizedTitle, image: UIImage(systemName: type.imageSystemName), options: .destructive, children: [action])
	}
}
