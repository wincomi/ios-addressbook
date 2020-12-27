//
//  CallDirectoryEntryListViewModel.swift
//  addressbook
//

import SwiftUI
import CallKit

enum CallDirectoryEntryListError: Error {
	case callDirectoryManagerEnabledStatusUnknown
	case callDirectoryManagerEnabledStatusDisabled
	case error(Error?)
}

final class CallDirectoryEntryListViewModel: LoadableObject, ObservableObject {
	private let storageController = StorageController.shared
	let didChange = StorageController.didChange
	let entryType: CallDirectoryEntry.EntryType
	@Published var state: LoadingState<[CallDirectoryEntry], CallDirectoryEntryListError> = .idle

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

	func load() {
		#if DEBUG
		let callDirectoryEntries = self.storageController.fetchCallDirectoryEntries(type: self.entryType)
		self.state = .loaded(callDirectoryEntries)
		#else
		CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: AppSettings.callDirectoryBundleIdentifier) { (enabledStatus, error) in
			if let error = error {
				self.state = .failed(.error(error))
				return
			}

			switch enabledStatus {
			case .unknown:
				self.state = .failed(.callDirectoryManagerEnabledStatusUnknown)
			case .disabled:
				self.state = .failed(.callDirectoryManagerEnabledStatusDisabled)
			case .enabled:
				let callDirectoryEntries = self.storageController.fetchCallDirectoryEntries(type: self.entryType)
				self.state = .loaded(callDirectoryEntries)
			@unknown default:
				self.state = .failed(.error(nil))
			}
		}
		#endif
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		StorageController.shared.remove(callDirectoryEntry)
	}

	func reloadCallDirectoryExtension() {
		let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		sceneDelegate?.reloadCallDirectoryExtension()
	}
}
