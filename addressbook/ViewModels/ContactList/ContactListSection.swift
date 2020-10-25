//
//  ContactListSection.swift
//  addressbook
//

import Contacts

typealias ContactListSection = LocalizedIndexedCollation<ContactListRow>.Section

extension ContactListSection {
	// MARK: - Making ContactListSection
	static func makeSections(from contacts: [CNContact], sortBy sortingKeyPath: KeyPath<ContactListRow, String> = \.text) -> [ContactListSection] {
		let rows = contacts.map(ContactListRow.init)
		let collation = LocalizedIndexedCollation(items: rows, sortBy: sortingKeyPath)
		return collation.sections
	}
}
