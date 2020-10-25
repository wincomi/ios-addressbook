//
//  SearchListSection.swift
//  addressbook
//

import UIKit

struct SearchListSection: SectionRepresentable, Hashable {
	enum MatchingType: Hashable {
		case name
		case phoneNumbers
		case emailAddresses
		case keyPath(KeyPath<ContactListRow, String>)
	}

	let type: MatchingType

	// MARK: - SectionRepresentable
	let headerText: String?
	let footerText: String?
	let rows: [SearchListRow]

	func hash(into hasher: inout Hasher) {
		hasher.combine(type)
	}

	// MARK: - Initialization
	init(matching type: MatchingType, rows: [SearchListRow]) {
		self.type = type
		self.headerText = {
			switch type {
			case .name:
				return L10n.SearchList.Section.Name.header
			case .phoneNumbers:
				return L10n.SearchList.Section.PhoneNumbers.header
			case .emailAddresses:
				return L10n.SearchList.Section.EmailAddresses.header
			case .keyPath:
				return nil
			}
		}()
		self.footerText = nil
		self.rows = rows
	}
}
