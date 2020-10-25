//
//  UserDefaults+Extension.swift
//  Shared
//

import Foundation

extension UserDefaults {
	static private let appGroupId = "group.com.wincomi.addressbook"

	/// Standard UserDefaults + AppGroup UserDefaults
	static var shared: UserDefaults {
		let combined = UserDefaults.standard
		combined.addSuite(named: appGroupId)
		return combined
	}

	static var appGroup: UserDefaults {
		return UserDefaults(suiteName: appGroupId)!
	}
}

