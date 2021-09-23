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

		var localizedTitle: String {
			switch self {
			case .any:
				return NSLocalizedString("FilterType.any", comment: "")
			case .sender:
				return NSLocalizedString("FilterType.sender", comment: "")
			case .messageBody:
				return NSLocalizedString("FilterType.messageBody", comment: "")
			}
		}

		var systemImageName: String {
			switch self {
			case .any:
				return "message"
			case .sender:
				return "person.fill.questionmark"
			case .messageBody:
				return "text.bubble"
			}
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

		var localizedTitle: String {
			switch self {
			case .none:
				return NSLocalizedString("FilterAction.none", comment: "")
			case .allow:
				return NSLocalizedString("FilterAction.allow", comment: "")
			case .junk:
				return NSLocalizedString("FilterAction.junk", comment: "")
			case .transaction:
				return NSLocalizedString("FilterAction.transaction", comment: "")
			case .promotion:
				return NSLocalizedString("FilterAction.promotion", comment: "")
			}
		}

		var systemImageName: String {
			switch self {
			case .none:
				return "questionmark.circle"
			case .allow:
				return "checkmark.seal"
			case .junk:
				return "xmark.bin"
			case .transaction:
				return "arrow.left.arrow.right"
			case .promotion:
				return "megaphone"
			}
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
