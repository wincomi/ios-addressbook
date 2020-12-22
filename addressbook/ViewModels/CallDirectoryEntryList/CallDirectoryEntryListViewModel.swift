//
//  CallDirectoryEntryListViewModel.swift
//  addressbook
//

import SwiftUI
import CallKit

final class CallDirectoryEntryListViewModel: ObservableObject {
	@Published var callDirectoryManagerEnabledStatus: CXCallDirectoryManager.EnabledStatus?
	@Published var callDirectoryEntries: [CallDirectoryEntry] = []

	private let storageController = StorageController.shared
	let didChange = StorageController.didChange
	let entryType: CallDirectoryEntry.EntryType

	var navigationTitle: String {
		switch entryType {
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.navigationTitle
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.navigationTitle
		}
	}

	init(type: CallDirectoryEntry.EntryType) {
		self.entryType = type
	}

	func update() {
		#if DEBUG
		self.callDirectoryManagerEnabledStatus = .enabled
		#else
		CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: AppSettings.callDirectoryBundleIdentifier) { (enabledStatus, error) in
			DispatchQueue.main.async {
				self.callDirectoryManagerEnabledStatus = enabledStatus
			}
		}
		#endif

		if case .enabled = self.callDirectoryManagerEnabledStatus {
			self.callDirectoryEntries = storageController.fetchCallDirectoryEntries(type: entryType)
		}
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		StorageController.shared.remove(callDirectoryEntry)
	}

	func reloadCallDirectoryExtension() {
		let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		sceneDelegate?.reloadCallDirectoryExtension()
	}
}
