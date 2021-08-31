//
//  ApplicationShortcutItemSettingForm.swift
//  addressbook
//

import SwiftUI

struct ApplicationShortcutItemSettingForm: View {
	@EnvironmentObject var appSettings: AppSettings

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
			// MARK: - AddingSection
			if !itemsCanBeAdded.isEmpty {
				Section(
					header: Text(L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems),
					footer: Text(L10n.ApplicationShortcutItemsSettingForm.AddingSection.footer)
				) {
					ForEach(itemsCanBeAdded, id: \.localizedTitle) { applicationShortcutItem in
						ApplicationShortcutItemSettingFormCell(applicationShortcutItem: applicationShortcutItem, type: .add) {
							appSettings.applicationShortcutItems.append(applicationShortcutItem)
						}
					}
				}
			}
			// MARK: - ItemsSection
			if !appSettings.applicationShortcutItems.isEmpty {
				Section(
					header: Text(L10n.ApplicationShortcutItemsSettingForm.title),
					footer: Text(L10n.ApplicationShortcutItemsSettingForm.ItemsSection.footer)
				) {
					ForEach(appSettings.applicationShortcutItems) { applicationShortcutItem in
						ApplicationShortcutItemSettingFormCell(applicationShortcutItem: applicationShortcutItem)
					}
					.onMove(perform: move)
					.onDelete(perform: remove)
				}
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.ApplicationShortcutItemsSettingForm.navigationTitle)
		.navigationBarItems(trailing: EditButton().disabled(appSettings.applicationShortcutItems.isEmpty))
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
