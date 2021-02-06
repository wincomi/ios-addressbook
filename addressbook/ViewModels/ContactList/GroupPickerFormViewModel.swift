//
//  GroupPickerFormViewModel.swift
//  addressbook
//

import SwiftUI

final class GroupPickerFormViewModel: LoadableObject, ObservableObject {
	@Published private(set) var state: LoadingState<[GroupListSection], Error> = .idle

	func load() {
		state = .loading

		do {
			let containers = try ContactStore.shared.fetchContainers()
			let sections = try GroupListSection.makeSections(from: containers)
			state = .loaded(sections.filter { !$0.rows.isEmpty })
		} catch {
			state = .failed(error)
		}
	}
}
