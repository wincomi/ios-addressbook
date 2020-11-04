//
//  CallDirectoryHandler.swift
//  CallDirectory
//

import Foundation
import CallKit
import CoreData

final class CallDirectoryHandler: CXCallDirectoryProvider {
	override func beginRequest(with context: CXCallDirectoryExtensionContext) {
		context.delegate = self

		if let lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date, context.isIncremental {
			addOrRemoveIncrementalBlockingPhoneNumbers(to: context, since: lastUpdate)
			addOrRemoveIncrementalIdentificationPhoneNumbers(to: context, since: lastUpdate)
		} else {
			addAllBlockingPhoneNumbers(to: context)
			addAllIdentificationPhoneNumbers(to: context)
		}

		UserDefaults.standard.set(Date(), forKey: "lastUpdate")

		context.completeRequest()
	}

	private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
		let fetchRequest = CallDirectoryEntry.fetchRequest(callDirectoryEntryType: .blocking)
		let callDirectoryEntries = SharedPersistentContainerManager.shared.fetch(fetchRequest)

		callDirectoryEntries.forEach { callDirectoryEntry in
			context.addBlockingEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber)
			print(callDirectoryEntry.phoneNumber)
		}
	}

	private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
		let fetchRequest = CallDirectoryEntry.fetchRequest(callDirectoryEntryType: .blocking, isRemoved: true, since: date)
		let callDirectoryEntries = SharedPersistentContainerManager.shared.fetch(fetchRequest)

		callDirectoryEntries.forEach { callDirectoryEntry in
			if callDirectoryEntry.isRemoved {
				context.removeBlockingEntry(withPhoneNumber: callDirectoryEntry.phoneNumber)
			} else {
				context.addBlockingEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber)
			}
		}
	}

	private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
		let fetchRequest = CallDirectoryEntry.fetchRequest(callDirectoryEntryType: .identification)
		let callDirectoryEntries = SharedPersistentContainerManager.shared.fetch(fetchRequest)

		callDirectoryEntries.forEach { callDirectoryEntry in
			guard let name = callDirectoryEntry.name else { return }
			context.addIdentificationEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber, label: name)
		}
	}

	private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext, since date: Date) {
		let fetchRequest = CallDirectoryEntry.fetchRequest(callDirectoryEntryType: .identification, isRemoved: true, since: date)
		let callDirectoryEntries = SharedPersistentContainerManager.shared.fetch(fetchRequest)

		callDirectoryEntries.forEach { callDirectoryEntry in
			if callDirectoryEntry.isRemoved {
				context.removeIdentificationEntry(withPhoneNumber: callDirectoryEntry.phoneNumber)
			} else {
				guard let name = callDirectoryEntry.name else { return }
				context.addIdentificationEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber, label: name)
			}
		}
	}
}

// MARK: - CXCallDirectoryExtensionContextDelegate
extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
	func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {

	}
}
