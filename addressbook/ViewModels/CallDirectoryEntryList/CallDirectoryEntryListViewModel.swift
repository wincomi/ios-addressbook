//
//  CallDirectoryEntryListViewModel.swift
//  addressbook
//

import CoreData
import SwiftUI
import CallKit

final class CallDirectoryEntryListViewModel: NSObject, ObservableObject {
	private let fetchedResultsController: NSFetchedResultsController<CallDirectoryEntry>

	var entryType: CallDirectoryEntry.EntryType
	var navigationBarTitle: String {
		switch entryType {
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.navigationTitle
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.navigationTitle
		}
	}

	@Published var callDirectoryManagerEnabledStatus: CXCallDirectoryManager.EnabledStatus?
	@Published var callDirectoryEntries: [CallDirectoryEntry] = []

	init(type: CallDirectoryEntry.EntryType) {
		self.entryType = type
		self.fetchedResultsController = NSFetchedResultsController(
			fetchRequest: CallDirectoryEntry.fetchRequest(isBlocked: type.isBlocked),
			managedObjectContext: SharedPersistentContainerManager.shared.context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)

		super.init()

		self.fetchedResultsController.delegate = self

		do {
			try fetchedResultsController.performFetch()
			self.callDirectoryEntries = fetchedResultsController.fetchedObjects ?? []
		} catch {
			print(error.localizedDescription)
		}
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
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		SharedPersistentContainerManager.shared.remove(callDirectoryEntry)
	}

	private func reloadCallDirectoryExtension() {
		let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
		sceneDelegate?.reloadCallDirectoryExtension()
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension CallDirectoryEntryListViewModel: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		guard let callDirectoryEntries = controller.fetchedObjects as? [CallDirectoryEntry] else { return }
		self.callDirectoryEntries = callDirectoryEntries

		reloadCallDirectoryExtension()
	}
}
