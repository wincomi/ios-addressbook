//
//  View+onDragCompatible.swift
//  addressbook
//

import SwiftUI

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
	public func onDragCompatible(_ data: @escaping () -> NSItemProvider) -> some View {
		if #available(iOS 13.4, *) {
			return AnyView(self.onDrag(data))
		} else {
			return AnyView(self)
		}
	}
}

