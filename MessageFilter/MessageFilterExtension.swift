//
//  MessageFilterExtension.swift
//  MessageFilter
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {
	let storageController = StorageController.shared

	func fetchMessageFilters() -> [MessageFilter] {
		return storageController.fetch(MessageFilter.fetchRequest())
	}

	func needToFilter(messageFilter: MessageFilter, sender: String, messageBody: String) -> Bool {
		var textToFilter = ""

		switch messageFilter.type {
		case .any:
			textToFilter = "\(sender) \(messageBody)"
		case .sender:
			textToFilter = sender
		case .messageBody:
			textToFilter = messageBody
		}

		if !messageFilter.isCaseSensitive {
			textToFilter = textToFilter.lowercased()
		}

		return textToFilter.contains(messageFilter.filterText)
	}

	func messageFilterAction(messageFilters: [MessageFilter], sender: String, messageBody: String) -> ILMessageFilterAction {
		for messageFilter in messageFilters {
			if needToFilter(messageFilter: messageFilter, sender: sender, messageBody: messageBody) {
				switch messageFilter.action {
				case .junk:
					return .junk
				case .promotion:
					if #available(iOSApplicationExtension 14.0, *) {
						return .promotion
					} else {
						return .junk
					}
				case .transaction:
					if #available(iOSApplicationExtension 14.0, *) {
						return .transaction
					} else {
						return .junk
					}
				case .none:
					return .none
				case .allow:
					return .allow
				}
			}
		}

		return .none
	}
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
	func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
		let response = ILMessageFilterQueryResponse()

		guard let sender = queryRequest.sender, let messageBody = queryRequest.messageBody else {
			response.action = .none
			completion(response)
			return
		}

		let messageFilters = fetchMessageFilters()
		response.action = messageFilterAction(messageFilters: messageFilters, sender: sender, messageBody: messageBody)
		completion(response)
	}
}
