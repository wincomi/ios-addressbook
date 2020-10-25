//
//  ContactListViewModel.swift
//  addressbook
//

import Combine
import Contacts

final class ContactListViewModel: ObservableObject {
	typealias ContactListState = ContactListViewController.State

	let groupListRow: GroupListRow
	private var cancellables = Set<AnyCancellable>()

	// MARK: - Outputs
	@Published private(set) var listState: ContactListState
	@Published private(set) var navigationTitle: String
	@Published var alertItem: AlertItem?
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

	func add(_ contactListRows: [ContactListRow], to group: CNGroup) {
		do {
			let contacts = contactListRows.map(\.contact)

			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
		} catch {
			alertItem = AlertItem(error: error)
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
		switch ContactStore.authrozationStatus {
		case .authorized:
			do {
				let contacts: [CNContact] = try {
					switch groupListRow.type {
					case .allContacts(in: let container):
						let contacts = try ContactStore.shared.fetchContacts(in: container)
						return contacts
					case .group(let group):
						let contacts = try ContactStore.shared.fetchContacts(in: group)
						return contacts
					}
				}()
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
}
