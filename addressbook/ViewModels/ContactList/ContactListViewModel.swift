//
//  ContactListViewModel.swift
//  addressbook
//

import Contacts
import Combine
import UIKit
import MobileCoreServices

final class ContactListViewModel: ObservableObject {
	typealias ContactListState = ContactListViewController.State

	let groupListRow: GroupListRow
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Outputs
	@Published private(set) var listState: ContactListState
	@Published private(set) var navigationTitle: String
	@Published var activityItems: [Any]?

	// MARK: - Inputs
	private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
	func viewDidLoad() {
		viewDidLoadProperty.send()
	}

	private let refreshProperty = PassthroughSubject<Void, Never>()
	func refresh() {
		refreshProperty.send()
	}

	func delete(_ contactListRows: [ContactListRow]) throws {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.delete(contact)
			}
		} catch {
			throw error
		}
	}

	func remove(_ contactListRows: [ContactListRow], from group: CNGroup) throws {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.remove(contact, from: group)
			}
		} catch {
			throw error
		}
	}

	func share(_ contactListRows: [ContactListRow]) throws {
		do {
			let contacts = contactListRows.map(\.contact)

			let activityItem = try ContactsItemSource(contacts)
			activityItems = [activityItem]
		} catch {
			throw error
		}
	}

	func dragItems(contact: CNContact) -> [UIDragItem]? {
		let itemProvider = NSItemProvider(object: contact)

		if let data = try? CNContactVCardSerialization.data(with: [contact]) {
			itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeVCard as String, visibility: .all) { completion in
				completion(data, nil)
				return nil
			}
		}

		return [UIDragItem(itemProvider: itemProvider)]
	}

	func add(_ contactListRows: [ContactListRow], to group: CNGroup) throws {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
		} catch {
			throw error
		}
	}

	// MARK: - Initialization
	init(groupListRow: GroupListRow) {
		self.groupListRow = groupListRow
		self.navigationTitle = groupListRow.navigationTitle
		self.listState = .loading

		Publishers.Merge3(viewDidLoadProperty, refreshProperty, ContactStore.didChange).sink {
			self.listState = self.fetchListState()
		}.store(in: &cancellables)
	}

	// MARK: - Fetching List State
	private func fetchListState() -> ContactListState {
		switch ContactStore.authorizationStatus {
		case .authorized:
			do {
				let contacts = try fetchContacts(groupListRow: groupListRow)
				let sections = ContactListSection.makeSections(from: contacts, sortBy: \.sortingString)
				return .loaded(sections)
			} catch {
				return .error(.cannotFetch)
			}
		case .notDetermined:
			return .error(.accessNotDetermined)
		case .restricted:
			return .error(.accessRestricted)
		case .denied:
			return .error(.accessDenied)
		@unknown default:
			return .error(.unknown)
		}
	}

	private func fetchContacts(groupListRow: GroupListRow) throws -> [CNContact] {
		switch groupListRow.type {
		case .allContacts(in: let container):
			let contacts = try ContactStore.shared.fetchContacts(in: container)
			return contacts
		case .group(let group):
			let contacts = try ContactStore.shared.fetchContacts(in: group)
			return contacts
		}
	}
}
