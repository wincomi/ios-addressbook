//
//  SidebarListViewModel.swift
//  addressbook
//

import SwiftUI
import Contacts
import CoreServices

final class SidebarListViewModel: ObservableObject {
	@Published var groupListSections = [GroupListSection]()

	func update() {
		guard case .authorized = ContactStore.authorizationStatus else { return }

		do {
			let containers = try ContactStore.shared.fetchContainers()
			let sections = try GroupListSection.makeSections(from: containers, withAllContactsSection: true, withAllContactsRow: containers.count > 1)
			self.groupListSections = sections
		} catch {
			self.groupListSections = []
		}
	}

	func delete(_ group: CNGroup, completion: ((Error?) -> Void)) {
		do {
			try ContactStore.shared.delete(group)
			completion(nil)
		} catch {
			completion(error)
		}
	}

	func add(_ contacts: [CNContact], to group: CNGroup, completion: ((Error?) -> Void)) {
		do {
			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
			completion(nil)
		} catch {
			completion(error)
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
		update() // To update context menu in view
	}

	func removeApplicationShortcutItemFromAppSettings(_ applicationShortcutItem: ApplicationShortcutItem) {
		AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
		update()
	}
}
