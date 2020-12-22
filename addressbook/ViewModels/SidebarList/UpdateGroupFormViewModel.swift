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

	func updateGroup(withGroupName groupName: String, completion: ((Error?) -> Void)) {
		do {
			try currentGroup.update { $0.name = groupName }
			completion(nil)
		} catch {
			completion(error)
		}
	}
}
