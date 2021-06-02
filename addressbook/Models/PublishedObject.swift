//
//  PublishedObject.swift
//  addressbook
//

import SwiftUI
import Combine
/*
class PublishedObject<P: Publisher>: LoadableObject {
	@Published private(set) var state = LoadingState<P.Output, P.Failure>.idle

	private let publisher: P
	private var cancellable: AnyCancellable?

	init(publisher: P) {
		self.publisher = publisher
	}

	func load() {
		state = .loading

		cancellable = publisher
			.map(LoadingState.loaded)
			.catch { error in
				Just(LoadingState.failed(error))
			}
			.sink { [weak self] state in
				self?.state = state
			}
	}
}

extension AsyncContentView {
	init<P: Publisher>(
		source: P,
		@ViewBuilder content: @escaping (P.Output) -> Content
	) where Source == PublishedObject<P> {
		self.init(
			source: PublishedObject(publisher: source),
			content: content
		)
	}
}
*/
