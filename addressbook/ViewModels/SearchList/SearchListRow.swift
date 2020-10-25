//
//  SearchListRow.swift
//  addressbook
//

import UIKit

struct SearchListRow: RowRepresentable, Hashable {
	let contactListRow: ContactListRow
	let searchText: String
	let matchingType: SearchListSection.MatchingType

	// MARK: - RowRepresentable
	var text: String {
		contactListRow.text
	}

	var secondaryText: String? {
		contactListRow.secondaryText
	}

	var image: UIImage? {
		contactListRow.image
	}

	// MARK: - Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(matchingType)
		hasher.combine(contactListRow)
	}

	// MARK: - Initialization
	init(_ contactListRow: ContactListRow, searchText: String, matching matchingType: SearchListSection.MatchingType) {
		self.contactListRow = contactListRow
		self.searchText = searchText
		self.matchingType = matchingType
	}
}
