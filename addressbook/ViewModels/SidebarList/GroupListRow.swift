//
//  GroupListRow.swift
//  addressbook
//

import UIKit
import Contacts
import CoreServices

struct GroupListRow: RowRepresentable, Identifiable, Hashable {
	enum `Type`: Hashable {
		case allContacts(in: CNContainer?)
		case group(CNGroup)
	}

	let type: Type
	let navigationTitle: String

	// MARK: - RowRepresentable
	let text: String
	let secondaryText: String?
	let image: UIImage?

	// MARK: - Identifiable
	let id: Type

	// MARK: - Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	// MARK: - Making All Contacts Row
	static func allContacts(in container: CNContainer? = nil) -> GroupListRow {
		GroupListRow(type: .allContacts(in: container))
	}

	// MARK: - Initialization
	init(_ group: CNGroup) {
		self.init(type: .group(group))
	}

	init?(groupIdentifier: String) {
		guard let groups = try? ContactStore.shared.fetchGroups(withIdentifiers: [groupIdentifier]),
			  let group = groups.first else { return nil }
		self.init(group)
	}

	private init(type: Type) {
		self.type = type
		self.id = type

		switch type {
		case .allContacts(let container):
			self.navigationTitle = container?.displayName ?? L10n.allContacts
			self.text = L10n.allContacts
			self.secondaryText = nil
			self.image = nil
		case .group(let group):
			self.navigationTitle = group.name
			self.text = group.name
			self.secondaryText = nil
			self.image = nil
		}
	}

	// MARK: - Fetching Contacts
	func fetchContacts() throws -> [CNContact] {
		do {
			switch type {
			case .allContacts(in: let container):
				let contacts = try ContactStore.shared.fetchContacts(in: container)
				return contacts
			case .group(let group):
				let contacts = try ContactStore.shared.fetchContacts(in: group)
				return contacts
			}
		} catch {
			throw error
		}
	}
}
