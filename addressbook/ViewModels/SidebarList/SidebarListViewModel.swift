//
//  SidebarListViewModel.swift
//  addressbook
//

import SwiftUI
import Contacts
import CoreServices
import Combine

final class SidebarListViewModel: LoadableObject, ObservableObject {
	@Published private(set) var state: LoadingState<[GroupListSection], Error> = .idle

	func load() {
		switch ContactStore.authorizationStatus {
		case .authorized:
			do {
				var containers = try ContactStore.shared.fetchContainers()
				if AppSettings.shared.hideLocalContainer {
					containers = containers.filter { $0.type != .local }
				}
				let sections = try GroupListSection.makeSections(from: containers, withAllContactsSection: true, withAllContactsRow: containers.count > 1)
				self.state = .loaded(sections)
			} catch {
				self.state = .failed(error)
			}
		case .notDetermined:
			self.state = .failed(ContactStoreError.accessNotDetermined)
		case .denied:
			self.state = .failed(ContactStoreError.accessDenied)
		case .restricted:
			self.state = .failed(ContactStoreError.accessRestricted)
		default:
			self.state = .failed(ContactStoreError.unknown)
		}
	}

	func delete(_ group: CNGroup) throws {
		do {
			try ContactStore.shared.delete(group)
		} catch {
			throw error
		}
	}

	func add(_ contacts: [CNContact], to group: CNGroup) throws {
		do {
			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
		} catch {
			throw error
		}
	}

	func itemProvider(for groupListRow: GroupListRow) -> NSItemProvider? {
		guard let contacts = try? groupListRow.fetchContacts(),
			  let data = try? CNContactVCardSerialization.data(with: contacts) else { return nil }

		let itemProvider = NSItemProvider()
		itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeVCard as String, visibility: .all) { completion in
			completion(data, nil)
			return nil
		}

		return itemProvider
	}

	func activityItems(for groupListRow: GroupListRow) -> [Any]? {
		do {
			let contacts = try groupListRow.fetchContacts()
			let itemSource = try ContactsItemSource(contacts)
			return [itemSource]
		} catch {
			return nil
		}
	}

	func addApplicationShortcutItemToAppSettings(_ applicationShortcutItem: ApplicationShortcutItem) {
		AppSettings.shared.applicationShortcutItems.append(applicationShortcutItem)
		load() // To update context menu in view
	}

	func removeApplicationShortcutItemFromAppSettings(_ applicationShortcutItem: ApplicationShortcutItem) {
		AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
		load()
	}
}
