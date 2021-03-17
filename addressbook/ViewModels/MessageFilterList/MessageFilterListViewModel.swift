//
//  MessageFilterListViewModel.swift
//  addressbook
//

import Combine

final class MessageFilterListViewModel: ObservableObject, LoadableObject {
	private let storageController = StorageController.shared
	@Published private(set) var state: LoadingState<[MessageFilter], Error> = .idle

	func load() {
		let messageFilters = storageController.fetch(MessageFilter.fetchRequest())
		state = .loaded(messageFilters)
	}
}
