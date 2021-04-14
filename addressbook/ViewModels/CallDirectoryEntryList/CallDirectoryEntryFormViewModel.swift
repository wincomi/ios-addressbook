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
		reloadCallDirectoryExtension()
	}

	// MARK: - Fix me
	func update(_ callDirectoryEntry: CallDirectoryEntry, entryType: CallDirectoryEntry.EntryType, name: String, phoneNumber: Int64) {
		storageController.edit(callDirectoryEntry) {
			$0.isBlocked = entryType.isBlocked
			$0.name = name
			$0.phoneNumber = phoneNumber
		}
		reloadCallDirectoryExtension()
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		storageController.remove(callDirectoryEntry)
		reloadCallDirectoryExtension()
	}

	func reloadCallDirectoryExtension() {
		let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		sceneDelegate?.reloadCallDirectoryExtension()
	}
}
