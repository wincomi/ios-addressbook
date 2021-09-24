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

		context.removeAllBlockingEntries()
		context.removeAllIdentificationEntries()

		addAllBlockingPhoneNumbers(to: context)
		addAllIdentificationPhoneNumbers(to: context)

		UserDefaults.standard.set(Date(), forKey: "lastUpdate")

		context.completeRequest()
	}

	private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
		let callDirectoryEntries = StorageController.shared.fetchCallDirectoryEntries(type: .blocking)

		callDirectoryEntries.forEach { callDirectoryEntry in
			context.addBlockingEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber)
		}
	}

	private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
		let callDirectoryEntries = StorageController.shared.fetchCallDirectoryEntries(type: .identification)

		callDirectoryEntries.forEach { callDirectoryEntry in
			guard let name = callDirectoryEntry.name else { return }
			context.addIdentificationEntry(withNextSequentialPhoneNumber: callDirectoryEntry.phoneNumber, label: name)
		}
	}
}

// MARK: - CXCallDirectoryExtensionContextDelegate
extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
	func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {

	}
}
