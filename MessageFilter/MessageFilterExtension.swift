//
//  MessageFilterExtension.swift
//  MessageFilter
//

import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
	func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
		let response = ILMessageFilterQueryResponse()

		guard let sender = queryRequest.sender, let messageBody = queryRequest.messageBody else {
			response.action = .none
			completion(response)
			return
		}

		response.action = .none

		completion(response)
	}
}
