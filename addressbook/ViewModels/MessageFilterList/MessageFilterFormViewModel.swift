//
//  MessageFilterFormViewModel.swift
//  addressbook
//

import Combine

final class MessageFilterFormViewModel: ObservableObject {
	private let storageController = StorageController.shared

	func createMessageFilter(type: MessageFilter.FilterType, text: String, isCaseSensitive: Bool, action: MessageFilter.FilterAction) {
		let messageFilter = MessageFilter(context: StorageController.shared.context)
		messageFilter.isEnabled = true
		messageFilter.filterText = text
		messageFilter.isCaseSensitive = isCaseSensitive
		messageFilter.type = type
		messageFilter.action = action

		storageController.saveContext()
	}

	func update(_ messageFilter: MessageFilter, type: MessageFilter.FilterType, text: String, isCaseSensitive: Bool, action: MessageFilter.FilterAction) {
		messageFilter.isEnabled = true
		messageFilter.filterText = text
		messageFilter.isCaseSensitive = isCaseSensitive
		messageFilter.type = type
		messageFilter.action = action

		storageController.saveContext()
	}

	func delete(_ messageFilter: MessageFilter) {
		storageController.context.delete(messageFilter)
		storageController.saveContext()
	}
}
