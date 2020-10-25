//
//  GroupListViewModel.swift
//  addressbook
//

import Contacts
import Combine

final class GroupListViewModel: ObservableObject {
	typealias GroupListState = GroupListViewController.State

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Outputs
	@Published private(set) var listState: GroupListState
	@Published private(set) var allContainers: [CNContainer]
	@Published var alertItem: AlertItem?
	@Published var activityItems: [Any]?

	// MARK: - Inputs
	private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
	public func viewDidLoad() {
		viewDidLoadProperty.send()
	}

	private let refreshProperty = PassthroughSubject<Void, Never>()
	public func refresh() {
		refreshProperty.send()
	}

	func createGroup(groupName: String, to container: CNContainer) {
		do {
			try ContactStore.shared.create(group: { $0.name = groupName }, to: container)
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func update(_ group: CNGroup, groupName: String) {
		do {
			try group.update { $0.name = groupName }
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func delete(_ group: CNGroup) {
		do {
			try ContactStore.shared.delete(group)
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func share(_ groupListRow: GroupListRow) {
		do {
			let contacts = try groupListRow.fetchContacts()
			let itemSource = try ContactsItemSource(contacts)

			activityItems = [itemSource]
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	func add(_ contacts: [CNContact], to group: CNGroup) {
		do {
			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
		} catch {
			alertItem = AlertItem(error: error)
		}
	}

	// MARK: - Initialization
	init() {
		self.listState = .error(.accessNotDetermined)
		self.allContainers = []

		Publishers.Merge3(viewDidLoadProperty, refreshProperty, ContactStore.didChange).sink {
			self.listState = self.fetchListState()
			self.allContainers = self.fetchContainers() ?? []
		}.store(in: &cancellables)
	}

	// MARK: - Fetching List State
	private func fetchListState() -> GroupListState {
		switch ContactStore.authrozationStatus {
		case .authorized:
			do {
				let containers = try ContactStore.shared.fetchContainers()
				let sections = try GroupListSection.makeSections(from: containers, withAllContactsSection: true, withAllContactsRow: containers.count > 1)
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

	private func fetchContainers() -> [CNContainer]? {
		switch ContactStore.authrozationStatus {
		case .authorized:
			let containers = try? ContactStore.shared.fetchContainers()
			return containers
		default:
			return nil
		}
	}
}
