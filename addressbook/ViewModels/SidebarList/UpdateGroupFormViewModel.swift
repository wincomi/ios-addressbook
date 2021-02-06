//
//  UpdateGroupFormViewModel.swift
//  addressbook
//

import SwiftUI
import Contacts

final class UpdateGroupFormViewModel: ObservableObject {
	let currentGroup: CNGroup

	init(currentGroup: CNGroup) {
		self.currentGroup = currentGroup
	}

	func updateGroup(withGroupName groupName: String) throws {
		do {
			try currentGroup.update { $0.name = groupName }
		} catch {
			throw error
		}
	}
}
