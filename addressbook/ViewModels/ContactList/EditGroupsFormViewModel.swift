//
//  EditGroupsFormViewModel.swift
//  addressbook
//

import Contacts

final class EditGroupsFormViewModel: LoadableObject, ObservableObject {
	@Published private(set) var state: LoadingState<[GroupListSection], Error> = .idle
	@Published private(set) var selection = Set<GroupListRow>()
	let contact: CNContact

	init(contact: CNContact) {
		self.contact = contact
	}

	func load() {
		do {
			let containers = try ContactStore.shared.fetchContainers()
			let sections = try GroupListSection.makeSections(from: containers)
			self.state = .loaded(sections.filter { !$0.rows.isEmpty })
		} catch {
			self.state = .failed(error)
		}
	}

	func fetchSelection() {
		do {
			let containers = try ContactStore.shared.fetchContainers()
			
			let groups = try containers.reduce([]) { result, container in
				result + (try ContactStore.shared.fetchGroups(in: container))
			}

			let groupsContainsContact = try groups.filter { group in
				let contacts = try ContactStore.shared.fetchContacts(in: group)
				return contacts.map(\.identifier).contains(contact.identifier)
			}

			self.selection = Set(groupsContainsContact.map(GroupListRow.init))
		} catch {
			self.selection = []
		}
	}

	func addContact(to groupListRow: GroupListRow) throws {
		guard case .group(let group) = groupListRow.type else { return }

		do {
			try ContactStore.shared.add(contact, to: group)
			selection.insert(groupListRow)
		} catch {
			throw error
		}
	}

	func removeContact(from groupListRow: GroupListRow) throws {
		guard case .group(let group) = groupListRow.type else { return }

		do {
			try ContactStore.shared.remove(contact, from: group)
			selection.remove(groupListRow)
		} catch {
			throw error
		}
	}
}
