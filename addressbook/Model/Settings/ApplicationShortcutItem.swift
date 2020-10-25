//
//  ApplicationShortcutItem.swift
//  addressbook
//

import UIKit

enum ApplicationShortcutItem: ApplicationShortcutItemRepresentable, RawRepresentable, Equatable {
	case contact(identifier: String)
	case group(identifier: String)
	case addContact
	case searchContacts

	// MARK: - ApplicationShortcutItemRepresentable
	var localizedTitle: String {
		switch self {
		case .contact(let identifier):
			let contactListRow = ContactListRow(contactIdentifier: identifier)
			return contactListRow?.text ?? L10n.unknownContact
		case .group(let identifier):
			let groupListRow = GroupListRow(groupIdentifier: identifier)
			return groupListRow?.text ?? L10n.unknownGroup
		case .addContact:
			return L10n.createNewContact
		case .searchContacts:
			return L10n.searchContacts
		}
	}

	var localizedSubtitle: String? { nil }
	var type: String { self.rawValue }

	var icon: UIApplicationShortcutIcon? {
		switch self {
		case .contact(let identifier):
			guard let contactListRow = ContactListRow(contactIdentifier: identifier) else { return nil }
			if contactListRow.contact.imageDataAvailable {
				return UIApplicationShortcutIcon(contact: contactListRow.contact)
			} else {
				return UIApplicationShortcutIcon(systemImageName: "person.circle")
			}
		case .group:
			return UIApplicationShortcutIcon(systemImageName: "folder")
		case .addContact:
			return UIApplicationShortcutIcon(type: .add)
		case .searchContacts:
			return UIApplicationShortcutIcon(type: .search)
		}
	}

	// MARK: - RawRepresentable
	var rawValue: String {
		switch self {
		case .contact(let identifier):
			return "\(AppSettings.bundleIdentifier).shortcutItem.contact.\(identifier)"
		case .group(let identifier):
			return "\(AppSettings.bundleIdentifier).shortcutItem.group.\(identifier)"
		case .addContact:
			return "\(AppSettings.bundleIdentifier).shortcutItem.addContact"
		case .searchContacts:
			return "\(AppSettings.bundleIdentifier).shortcutItem.searchContacts"
		}
	}

	// MARK: - Initialization
	init?(rawValue: String) {
		let contactPrefix = "\(AppSettings.bundleIdentifier).shortcutItem.contact."
		let groupPrefix = "\(AppSettings.bundleIdentifier).shortcutItem.group."

		switch rawValue {
		case _ where rawValue.hasPrefix(contactPrefix):
			let contactIdentifier = String(rawValue.dropFirst(contactPrefix.count))
			self = .contact(identifier: contactIdentifier)
		case _ where rawValue.hasPrefix(groupPrefix):
			let groupIdentifier = String(rawValue.dropFirst(groupPrefix.count))
			self = .group(identifier: groupIdentifier)
		case "\(AppSettings.bundleIdentifier).shortcutItem.addContact":
			self = .addContact
		case "\(AppSettings.bundleIdentifier).shortcutItem.searchContacts":
			self = .searchContacts
		default:
			return nil
		}
	}
}

extension ApplicationShortcutItem: RowRepresentable, Identifiable {
	// MARK: - RowRepresentable
	var text: String { localizedTitle }
	var secondaryText: String? { localizedSubtitle }
	var image: UIImage? {
		switch self {
		case .contact:
			return UIImage(systemName: "person.crop.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
		case .group:
			return UIImage(systemName: "folder", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
		case .addContact:
			return UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
		case .searchContacts:
			return UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
		}
	}

	// MARK: - Identifiable
	var id: String { rawValue }
}
