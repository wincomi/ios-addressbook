//
//  SearchListScope.swift
//  addressbook
//

import Contacts

enum SearchListScope {
	case allContacts
	case container(CNContainer)
	case group(CNGroup)

	static func scopeButtonTitles(from groupListRow: GroupListRow) -> [String]? {
		switch groupListRow.type {
		case .allContacts(in: let container):
			if let container = container {
				return [L10n.allContacts, container.displayName]
			} else {
				return nil
			}
		case .group(let group):
			return [L10n.allContacts, group.name]
		}
	}

	init?(groupListRow: GroupListRow, selectedScope: Int) {
		switch selectedScope {
		case 0:
			self = .allContacts
		case 1:
			switch groupListRow.type {
			case .allContacts(in: let container):
				if let container = container {
					self = .container(container)
				} else {
					return nil
				}
			case .group(let group):
				self = .group(group)
			}
		default:
			return nil
		}
	}
}
