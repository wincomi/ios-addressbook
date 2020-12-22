//
//  ApplicationShortcutItemSettingForm.swift
//  addressbook
//

import SwiftUI

struct ApplicationShortcutItemSettingForm: View {
	@ObservedObject var appSettings = AppSettings.shared

	private var itemsCanBeAdded: [ApplicationShortcutItem] {
		var items = [ApplicationShortcutItem]()
		if !appSettings.applicationShortcutItems.contains(.addContact) {
			items.append(.addContact)
		}
		if !appSettings.applicationShortcutItems.contains(.searchContacts) {
			items.append(.searchContacts)
		}
		return items
	}

	var body: some View {
		List {
			if !itemsCanBeAdded.isEmpty {
				addItemsSection
			}
			if !appSettings.applicationShortcutItems.isEmpty {
				itemsSection
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.ApplicationShortcutItemsSettingForm.navigationTitle)
		.navigationBarItems(trailing: EditButton().disabled(appSettings.applicationShortcutItems.isEmpty))
	}

	private var addItemsSection: some View {
		Section(
			header: Text(L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems).padding(.horizontal),
			footer: Text(L10n.ApplicationShortcutItemsSettingForm.AddingSection.footerText).padding(.horizontal)
		) {
			ForEach(itemsCanBeAdded, id: \.localizedTitle) { applicationShortcutItem in
				ApplicationShortcutItemSettingFormRowView(applicationShortcutItem: applicationShortcutItem, type: .add) {
					appSettings.applicationShortcutItems.append(applicationShortcutItem)
				}
			}
		}
	}

	private var itemsSection: some View {
		Section(
			header: Text(L10n.ApplicationShortcutItemsSettingForm.title).padding(.horizontal),
			footer: Text(L10n.ApplicationShortcutItemsSettingForm.Section.footerText).padding(.horizontal)
		) {
			ForEach(appSettings.applicationShortcutItems) { applicationShortcutItem in
				ApplicationShortcutItemSettingFormRowView(applicationShortcutItem: applicationShortcutItem)
			}
			.onMove(perform: move)
			.onDelete(perform: remove)
		}
	}

	private func move(from source: IndexSet, to destination: Int) {
		appSettings.applicationShortcutItems.move(fromOffsets: source, toOffset: destination)
	}

	private func remove(at offsets: IndexSet) {
		appSettings.applicationShortcutItems.remove(atOffsets: offsets)
	}
}

struct ApplicationShortcutItemSettingForm_Previews: PreviewProvider {
	static var previews: some View {
		ApplicationShortcutItemSettingForm()
	}
}
