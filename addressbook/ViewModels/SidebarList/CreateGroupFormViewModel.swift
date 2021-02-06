//
//  CreateGroupFormViewModel.swift
//  addressbook
//

import SwiftUI
import Contacts

final class CreateGroupFormViewModel: ObservableObject {
	@Published var containers = [CNContainer]()
	@Published var selectedContainer: CNContainer?

	func update() {
		self.containers = (try? ContactStore.shared.fetchContainers()) ?? []
		self.selectedContainer = containers.first
	}

	func createGroup(groupName: String) throws {
		guard let container = selectedContainer else { return }

		do {
			try ContactStore.shared.create(group: { $0.name = groupName }, to: container)
		} catch {
			throw error
		}
	}
}
