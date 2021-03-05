//
//  MessageFilterListViewModel.swift
//  addressbook
//

import Combine

final class MessageFilterListViewModel: ObservableObject, LoadableObject {
	@Published private(set) var state: LoadingState<[String], Error> = .idle

	func load() {
		state = .loaded(["test", "asdf"])
	}
}
