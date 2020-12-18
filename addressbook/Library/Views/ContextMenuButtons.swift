//
//  ContextMenuButtons.swift
//  addressbook
//

import SwiftUI
import MessageUI
import Contacts

enum ContextMenuButtons {
	struct SendMessageButton: View {
		let recipients: [String]
		let action: (([String]) -> Void)

		init?(for groupListRow: GroupListRow, action: @escaping (([String]) -> Void)) {
			guard MFMessageComposeViewController.canSendText(),
				  let contacts = try? groupListRow.fetchContacts() else { return nil }

			let phoneNumbers = contacts.map(\.phoneNumbers)
			if phoneNumbers.isEmpty { return nil }

			self.recipients = phoneNumbers.reduce([]) { $0 + $1.map(\.value.stringValue) }
			self.action = action
		}

		var body: some View {
			Button {
				action(recipients)
			} label: {
				Text(L10n.ContactListRow.ContextMenuItemType.sendMessage)
				Image(systemName: "message")
			}
		}
	}

	struct SendMailButton: View {
		let toRecipients: [String]
		let action: (([String]) -> Void)

		init?(for groupListRow: GroupListRow, action: @escaping (([String]) -> Void)) {
			guard MFMailComposeViewController.canSendMail(),
				  let contacts = try? groupListRow.fetchContacts() else { return nil }

			let emailAddress = contacts.map(\.emailAddresses)
			if emailAddress.isEmpty { return nil }

			self.toRecipients = emailAddress.reduce([]) { $0 + $1.map { $0.value as String } }
			self.action = action
		}

		var body: some View {
			Button {
				action(toRecipients)
			} label: {
				Text(L10n.ContactListRow.ContextMenuItemType.sendMail)
				Image(systemName: "envelope")
			}
		}
	}

	struct ApplicationShortcutItemSettingButton: View {
		let applicationShortcutItem: ApplicationShortcutItem
		let isEnabledInAppSettings: Bool
		let action: ((ApplicationShortcutItem, Bool) -> Void)

		init?(for groupListRow: GroupListRow, action: @escaping ((ApplicationShortcutItem, Bool) -> Void)) {
			guard case .group(let group) = groupListRow.type else { return nil }
			self.applicationShortcutItem = ApplicationShortcutItem.group(identifier: group.identifier)
			self.isEnabledInAppSettings = AppSettings.shared.applicationShortcutItems.contains(self.applicationShortcutItem)
			self.action = action
		}

		var body: some View {
			Button {
				action(applicationShortcutItem, isEnabledInAppSettings)
			} label: {
				if isEnabledInAppSettings {
					Text(L10n.ContactListRow.ContextMenuItemType.removeFromApplicationShortcutItems)
					Image(systemName: "minus.square")
				} else {
					Text(L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems)
					Image(systemName: "plus.app")
				}
			}
		}
	}

	struct ShareButton: View {
		let activityItems: [Any]
		let action: (([Any]) -> Void)

		init?(activityItems: [Any], action: @escaping (([Any]) -> Void)) {
			if activityItems.isEmpty {
				return nil
			}
			self.activityItems = activityItems
			self.action = action
		}
		
		var body: some View {
			Button {
				action(activityItems)
			} label: {
				Text(L10n.share)
				Image(systemName: "square.and.arrow.up")
			}
		}
	}

	struct RenameButton: View {
		let group: CNGroup
		let action: ((CNGroup) -> Void)

		init?(for groupListRow: GroupListRow, action: @escaping ((CNGroup) -> Void)) {
			guard case .group(let group) = groupListRow.type else { return nil }
			self.group = group
			self.action = action
		}

		var body: some View {
			Button {
				action(group)
			} label: {
				Text(L10n.GroupListRow.ContextMenuItemType.rename)
				Image(systemName: "pencil")
			}
		}
	}

	struct DeleteButton: View {
		let group: CNGroup
		let action: ((CNGroup) -> Void)

		init?(for groupListRow: GroupListRow, action: @escaping ((CNGroup) -> Void)) {
			guard case .group(let group) = groupListRow.type else { return nil }
			self.group = group
			self.action = action
		}

		var body: some View {
			Button {
				action(group)
			} label: {
				Text(L10n.delete)
				Image(systemName: "trash")
			}
		}
	}
}
