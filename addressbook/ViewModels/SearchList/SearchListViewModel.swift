//
//  SearchListViewModel.swift
//  addressbook
//

import Contacts
import Combine

final class SearchListViewModel: ObservableObject {
	let groupListRow: GroupListRow
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Outputs
	@Published private(set) var sections = [SearchListSection]()
	@Published var searchText = ""
	@Published var searchScope = SearchListScope.allContacts
	@Published var alertItem: AlertItem?
	@Published var activityItems: [Any]?

	// MARK: - Inputs
	func delete(_ contactListRows: [ContactListRow]) {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.delete(contact)
			}
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func remove(_ contactListRows: [ContactListRow], from group: CNGroup) {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.remove(contact, from: group)
			}
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func share(_ contactListRows: [ContactListRow]) {
		do {
			let contacts = contactListRows.map(\.contact)

			let activityItem = try ContactsItemSource(contacts)
			activityItems = [activityItem]
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	// MARK: - Initialization
	init(groupListRow: GroupListRow) {
		self.groupListRow = groupListRow

		Publishers.Merge3(
			$searchText,
			$searchScope.map { _ in self.searchText },
			ContactStore.didChange.map { _ in self.searchText }
		)
		.receive(on: DispatchQueue.main)
		.sink { searchText in
			self.sections = self.fetchSections(withSearchText: searchText)
		}
		.store(in: &cancellables)
	}

	// MARK: - 
	private func fetchSections(withSearchText searchText: String) -> [SearchListSection] {
		do {
			let contacts = try fetchContacts(searchScope: searchScope)
			let contactListRows = contacts.map(ContactListRow.init)
			let contactListRowsMatchingName = contactListRows.filter {
				$0.text.localizedStandardContains(searchText)
			}
			let searchTextDecimalDigits = searchText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
			let contactListRowsMatchingPhoneNumbers = contactListRows.filter {
				$0.contact.phoneNumbers.map {
					$0.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
				}.filter {
					$0.contains(searchTextDecimalDigits)
				}.count > 0
			}
			let contactListRowsMatchingEmailAddresses = contactListRows.filter {
				$0.contact.emailAddresses.map {
					$0.value as String
				}.filter {
					$0.localizedStandardContains(searchText)
				}.count > 0
			}
			let sections = [
				SearchListSection(
					matching: .name,
					rows: contactListRowsMatchingName.map {
						SearchListRow($0, searchText: searchText, matching: .name)
					}
				),
				SearchListSection(
					matching: .phoneNumbers,
					rows: contactListRowsMatchingPhoneNumbers.map {
						SearchListRow($0, searchText: searchText, matching: .phoneNumbers)
					}
				),
				SearchListSection(
					matching: .emailAddresses,
					rows: contactListRowsMatchingEmailAddresses.map {
						SearchListRow($0, searchText: searchText, matching: .emailAddresses)
					}
				)
			]
			return sections.filter { !$0.rows.isEmpty }
		} catch {
			return []
		}
	}

	private func fetchContacts(searchScope: SearchListScope) throws -> [CNContact] {
		switch searchScope {
		case .allContacts:
			let contacts = try ContactStore.shared.fetchContacts()
			return contacts
		case .container(let container):
			let contacts = try ContactStore.shared.fetchContacts(in: container)
			return contacts
		case .group(let group):
			let contacts = try ContactStore.shared.fetchContacts(in: group)
			return contacts
		}
	}
}
