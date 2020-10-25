//
//  CNContainer+Extension.swift
//  addressbook
//

import Contacts.CNContainer
import UIKit.UIDevice

public extension CNContainer {
	var displayName: String {
		switch type {
		case .local:
			return UIDevice.current.localizedModel
		case .exchange:
			return name.isEmpty ? "Exchange" : name
		case .cardDAV:
			return name.isEmpty ? "CardDAV" : name
		default:
			return name
		}
	}
}
