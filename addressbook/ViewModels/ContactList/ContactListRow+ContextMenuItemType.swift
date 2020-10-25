//
//  ContactListRow+ContextMenuItemType.swift
//  addressbook
//

extension ContactListRow {
	enum ContextMenuItemType: String, CaseIterable, Identifiable {
		case call
		case sendMessage
		case sendMail
		case share
		case applicationShortcutItemSetting
		case editGroups
		case removeFromGroup
		case delete

		var localizedTitle: String {
			switch self {
			case .call:
				return L10n.ContactListRow.ContextMenuItemType.call
			case .sendMessage:
				return L10n.ContactListRow.ContextMenuItemType.sendMessage
			case .sendMail:
				return L10n.ContactListRow.ContextMenuItemType.sendMail
			case .applicationShortcutItemSetting:
				return L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems
			case .share:
				return L10n.share
			case .editGroups:
				return L10n.EditGroupsForm.navigationTitle
			case .removeFromGroup:
				return L10n.ContactListRow.ContextMenuItemType.removeFromGroup
			case .delete:
				return L10n.delete
			}
		}

		var imageSystemName: String {
			switch self {
			case .call:
				return "phone"
			case .sendMessage:
				return "message"
			case .sendMail:
				return "envelope"
			case .applicationShortcutItemSetting:
				return "plus.app"
			case .share:
				return "square.and.arrow.up"
			case .editGroups:
				return "folder.badge.person.crop"
			case .removeFromGroup:
				return "minus.circle"
			case .delete:
				return "trash"
			}
		}

		// MARK: - Identifiable
		var id: String { rawValue }
	}
}
