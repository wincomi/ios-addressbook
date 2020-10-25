//
//  GroupListRow+ContextMenuItemType.swift
//  addressbook
//

extension GroupListRow {
	enum ContextMenuItemType: String, CaseIterable {
		case sendMessage
		case sendMail
		case share
		case rename
		case applicationShortcutItemSetting
		case delete

		var localizedTitle: String {
			switch self {
			case .sendMessage:
				return L10n.ContactListRow.ContextMenuItemType.sendMessage
			case .sendMail:
				return L10n.ContactListRow.ContextMenuItemType.sendMail
			case .applicationShortcutItemSetting:
				return L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems
			case .share:
				return L10n.share
			case .rename:
				return L10n.GroupListRow.ContextMenuItemType.rename
			case .delete:
				return L10n.delete
			}
		}

		var imageSystemName: String {
			switch self {
			case .sendMessage:
				return "message"
			case .sendMail:
				return "envelope"
			case .applicationShortcutItemSetting:
				return "plus.app"
			case .share:
				return "square.and.arrow.up"
			case .rename:
				return "pencil"
			case .delete:
				return "trash"
			}
		}
	}
}
