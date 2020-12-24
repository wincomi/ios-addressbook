//
//  Binding+Extension.swift
//  addressbook
//

import SwiftUI

extension Binding {
	/// onChange(of:perform:) Compatible
	func onUpdate(perform action: @escaping () -> Void) -> Binding<Value> {
		Binding(
			get: {
				wrappedValue
			},
			set: { newValue in
				wrappedValue = newValue
				action()
			}
		)
	}
}
