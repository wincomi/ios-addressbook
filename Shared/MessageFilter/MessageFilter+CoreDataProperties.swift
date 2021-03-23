//
//  MessageFilter+CoreDataProperties.swift
//  addressbook
//

import Foundation
import CoreData

extension MessageFilter {
	enum FilterType: Int32, CaseIterable, Identifiable {
		case any = 0
		case sender = 1
		case messageBody = 2

		var id: Int32 {
			rawValue
		}
	}

	// ILMessageFilterAction
	enum FilterAction: Int32, CaseIterable, Identifiable {
		case none = 0
		case allow = 1
		case junk = 2
		case transaction = 3
		case promotion = 4

		var id: Int32 {
			rawValue
		}
	}

	@nonobjc public class func fetchRequest() -> NSFetchRequest<MessageFilter> {
		return NSFetchRequest<MessageFilter>(entityName: "MessageFilter")
	}

	@NSManaged public var isEnabled: Bool
	@NSManaged private var filterType: Int32
	@NSManaged public var filterText: String
	@NSManaged public var isCaseSensitive: Bool
	@NSManaged private var filterAction: Int32

	var type: FilterType {
		get {
			FilterType(rawValue: filterType)!
		}
		set {
			filterType = newValue.rawValue
		}
	}

	var action: FilterAction {
		get {
			FilterAction(rawValue: filterAction)!
		}
		set {
			filterAction = newValue.rawValue
		}
	}
}

extension MessageFilter: Identifiable {
	public var id: String {
		filterText
	}
}
