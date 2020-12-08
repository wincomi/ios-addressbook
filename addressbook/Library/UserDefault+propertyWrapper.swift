//
//  UserDefault+propertyWrapper.swift
//  addressbook
//

import Foundation
import struct SwiftUI.Binding

@propertyWrapper public struct UserDefault<Value> {
	let store: UserDefaults

	let key: String
	let defaultValue: Value

	let getter: (() -> Value?)
	let setter: ((Value) -> Void)

	private init(_ key: String, defaultValue: Value, store: UserDefaults = .standard, getter: (() -> Value?)? = nil, setter: ((Value) -> Void)? = nil) {
		self.store = store
		self.key = key
		self.defaultValue = defaultValue
		self.getter = getter ?? { store.object(forKey: key) as? Value }
		self.setter = setter ?? { store.set( $0, forKey: key) }
	}

	public var wrappedValue: Value {
		get {
			return getter() ?? defaultValue
		}
		nonmutating set {
			setter(newValue)
		}
	}
}

extension UserDefault where Value == Bool {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store)
	}
}

extension UserDefault where Value: RawRepresentable, Value.RawValue == String {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			guard let rawValue = store.string(forKey: key) else { return nil }
			return Value(rawValue: rawValue)
		}, setter: { newValue in
			store.setValue(newValue.rawValue, forKey: key)
		})
	}
}

extension UserDefault where Value: RawRepresentable, Value.RawValue == Int {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			let rawValue = store.integer(forKey: key)
			return Value(rawValue: rawValue)
		}, setter: { newValue in
			store.setValue(newValue.rawValue, forKey: key)
		})
	}
}

extension UserDefault where Value: NSObject & NSCoding {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			guard let data = store.data(forKey: key),
				  let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Value else { return nil }
			return value
		}, setter: { newValue in
			guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData else { return }
			store.set(data, forKey: key)
		})
	}
}

// MARK: - Array
extension UserDefault where Value == Array<String> {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			return store.stringArray(forKey: key)
		})
	}
}

extension UserDefault where Value == Array<ContactListRow.ContextMenuItemType> {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			let rawValueArray = store.array(forKey: key) as? [Value.Element.RawValue]
			return rawValueArray?.compactMap(Value.Element.init(rawValue:))
		}, setter: { newValue in
			store.set(newValue.map(\.rawValue), forKey: key)
		})
	}
}

extension UserDefault where Value == Array<ApplicationShortcutItem> {
	public init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults = .standard) {
		self.init(key, defaultValue: defaultValue, store: store, getter: {
			let rawValueArray = store.array(forKey: key) as? [Value.Element.RawValue]
			return rawValueArray?.compactMap(Value.Element.init(rawValue:))
		}, setter: { newValue in
			store.set(newValue.map(\.rawValue), forKey: key)
		})
	}
}

