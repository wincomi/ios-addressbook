//
//  SidebarListViewModel.swift
//  addressbook
//

import SwiftUI
import Contacts

final class SidebarListViewModel: ObservableObject {
	@Published var groupListSections = [GroupListSection]()

	func update() {
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
		update()
	}

	func removeApplicationShortcutItemFromAppSettings(_ applicationShortcutItem: ApplicationShortcutItem) {
		AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
		update()
	}
}
