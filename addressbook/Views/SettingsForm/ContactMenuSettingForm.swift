//
//  ContactMenuSettingForm.swift
//  addressbook
//

import SwiftUI

struct ContactMenuSettingForm: View {
	@EnvironmentObject var appSettings: AppSettings
	@State private var selection = Set<ContactListRow.ContextMenuItemType>()

	private let types = ContactListRow.ContextMenuItemType.allCases

	var body: some View {
		List {
			Section(footer: Text(L10n.ContactMenuSettingForm.Section.footerText).padding(.horizontal)) {
				ForEach(types) { type in
					ContactMenuSettingFormCell(type: type, selection: $selection) {
						appSettings.enabledContactContextMenuItemsTypes = types.filter { selection.contains($0) }
					}
				}
			}
			Section(footer: Text(L10n.ContactMenuSettingForm.OptionsSection.footerText).padding(.horizontal)) {
				Toggle(L10n.ContactMenuSettingForm.OptionsSection.isContactContextMenuDisplayInline, isOn: $appSettings.isContactContextMenuDisplayInline)
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.ContactMenuSettingForm.navigationTitle)
		.onAppear(perform: update)
	}

	private func update() {
		selection = Set(appSettings.enabledContactContextMenuItemsTypes)
	}
}

struct ContactContextMenuSettingForm_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			ContactMenuSettingForm()
		}
	}
}
