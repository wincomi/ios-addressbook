//
//  CallDirectoryEntry+CoreDataProperties.swift
//  Shared
//

import Foundation
import CoreData

extension CallDirectoryEntry {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<CallDirectoryEntry> {
		return NSFetchRequest<CallDirectoryEntry>(entityName: "CallDirectoryEntry")
	}

	@nonobjc public class func fetchRequest(isBlocked: Bool, isRemoved: Bool = false, since date: Date? = nil) -> NSFetchRequest<CallDirectoryEntry> {
		let fetchRequest: NSFetchRequest<CallDirectoryEntry> = CallDirectoryEntry.fetchRequest()
		var predicates = [NSPredicate]()

		let isBlockedPredicate = NSPredicate(format: "isBlocked == %@", NSNumber(value: isBlocked))
		predicates.append(isBlockedPredicate)

		if !isRemoved {
			let isRemovedPredicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: false))
			predicates.append(isRemovedPredicate)
		}

		if let date = date {
			let updatedDatePredicate = NSPredicate(format: "updatedDate > %@", date as NSDate)
			predicates.append(updatedDatePredicate)
		}

		let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		fetchRequest.predicate = predicate
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "phoneNumber", ascending: true)]

		return fetchRequest
	}

	@NSManaged public var isBlocked: Bool
	@NSManaged public var isRemoved: Bool
	@NSManaged public var name: String?
	@NSManaged public var phoneNumber: Int64
	@NSManaged public var updatedDate: Date

	public var type: EntryType {
		isBlocked ? .blocking : .identification
	}
}

// MARK: - EntryType
extension CallDirectoryEntry {
	public enum EntryType {
		case identification
		case blocking

		var isBlocked: Bool {
			switch self {
			case .identification:
				return false
			case .blocking:
				return true
			}
		}
	}
}

// MARK: - Identifiable
extension CallDirectoryEntry: Identifiable {
	// Fix CallDirectoryEntryList is not changing when editing CallDirectoryEntry
	public var id: String {
		"\(isBlocked)-\(name ?? "")-\(phoneNumber)-\(String(describing: updatedDate))"
	}
}
