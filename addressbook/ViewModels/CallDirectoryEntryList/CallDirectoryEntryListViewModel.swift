//
//  CallDirectoryEntryListViewModel.swift
//  addressbook
//

import Combine
import SwiftUI
import CallKit
import CoreData

final class CallDirectoryEntryListViewModel: ObservableObject {
	@Published var callDirectoryManagerEnabledStatus: CXCallDirectoryManager.EnabledStatus?
	@Published var callDirectoryEntries: [CallDirectoryEntry] = []

	let storageController = StorageController.shared
	var entryType: CallDirectoryEntry.EntryType
	
	var navigationTitle: String {
		switch entryType {
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.navigationTitle
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.navigationTitle
		}
	}
	
	private var cancellables = Set<AnyCancellable>()
	
	init(type: CallDirectoryEntry.EntryType) {
		self.entryType = type
		
		NotificationCenter.default
			.publisher(for: .NSManagedObjectContextDidSave)
			.sink { notification in
				self.refresh()
			}.store(in: &cancellables)
	}

	func refresh() {
		#if DEBUG
		callDirectoryManagerEnabledStatus = .enabled
		#else
		CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: AppSettings.callDirectoryBundleIdentifier) { (enabledStatus, error) in
			DispatchQueue.main.async {
				self.callDirectoryManagerEnabledStatus = enabledStatus
			}
		}
		#endif
		
		if case .enabled = callDirectoryManagerEnabledStatus {
			callDirectoryEntries = storageController.fetchCallDirectoryEntries(type: entryType)
		}
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		StorageController.shared.remove(callDirectoryEntry)
	}

	private func reloadCallDirectoryExtension() {
		let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		sceneDelegate?.reloadCallDirectoryExtension()
	}
}
