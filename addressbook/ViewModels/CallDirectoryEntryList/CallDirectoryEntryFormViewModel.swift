//
//  CallDirectoryEntryFormViewModel.swift
//  addressbook
//

import SwiftUI

final class CallDirectoryEntryFormViewModel: ObservableObject {
	private let storageController = StorageController.shared

	func createCallDirectoryEntry(entryType: CallDirectoryEntry.EntryType, name: String, phoneNumber: Int64) {
		storageController.createCallDirectoryEntry(
			isBlocked: entryType.isBlocked,
			name: name,
			phoneNumber: phoneNumber
		)
	}

	func update(_ callDirectoryEntry: CallDirectoryEntry, entryType: CallDirectoryEntry.EntryType, name: String, phoneNumber: Int64) {
		storageController.edit(callDirectoryEntry) {
			$0.isBlocked = entryType.isBlocked
			$0.name = name
			$0.phoneNumber = phoneNumber
		}
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		StorageController.shared.remove(callDirectoryEntry)
	}
}
