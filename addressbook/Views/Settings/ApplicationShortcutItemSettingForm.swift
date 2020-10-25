//
//  ApplicationShortcutItemSettingForm.swift
//  addressbook
//

import SwiftUI

struct ApplicationShortcutItemSettingForm: View {
	@ObservedObject var appSettings = AppSettings.shared

	var body: some View {
		List {
			if !applicationShortcutItemsCanAdd.isEmpty {
				addingSection
			}
			if !appSettings.applicationShortcutItems.isEmpty {
				applicationShortcutItemsSection
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.ApplicationShortcutItemsSettingForm.navigationTitle)
		.navigationBarItems(trailing: EditButton().disabled(appSettings.applicationShortcutItems.isEmpty))
	}

	private var applicationShortcutItemsCanAdd: [ApplicationShortcutItem] {
		var applicationShortcutItems = [ApplicationShortcutItem]()
		if !appSettings.applicationShortcutItems.contains(.addContact) {
			applicationShortcutItems.append(.addContact)
		}
		if !appSettings.applicationShortcutItems.contains(.searchContacts) {
			applicationShortcutItems.append(.searchContacts)
		}
		return applicationShortcutItems
	}

	private var addingSection: some View {
		Section(header: Text(L10n.ContactListRow.ContextMenuItemType.addToApplicationShortcutItems), footer: Text(L10n.ApplicationShortcutItemsSettingForm.AddingSection.footerText)) {
			ForEach(applicationShortcutItemsCanAdd, id: \.localizedTitle) { applcationShortcutItem in
				addingSectionCell(for: applcationShortcutItem)
			}
		}
	}

	private func addingSectionCell(for applcationShortcutItem: ApplicationShortcutItem) -> some View {
		Button {
			appSettings.applicationShortcutItems.append(applcationShortcutItem)
		} label: {
			HStack(spacing: 12) {
				Image(systemName: "plus.circle.fill")
					.font(.system(size: 24))
					.foregroundColor(.green)
				Text(applcationShortcutItem.localizedTitle)
					.foregroundColor(Color(UIColor.label))
			}
		}
		.buttonStyle(BorderlessButtonStyle())
	}

	private var applicationShortcutItemsSection: some View {
		Section(header: Text(L10n.ApplicationShortcutItemsSettingForm.navigationTitle), footer: Text(L10n.ApplicationShortcutItemsSettingForm.Section.footerText)) {
			ForEach(appSettings.applicationShortcutItems) { applcationShortcutItem in
				ValueCellView(applcationShortcutItem, imageTintColor: AppSettings.shared.globalTintColor)
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

#if DEBUG
struct ApplicationShortcutItemSettingForm_Previews: PreviewProvider {
	static var previews: some View {
		ApplicationShortcutItemSettingForm()
	}
}
#endif
