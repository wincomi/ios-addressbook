//
//  ContactMenuSettingForm.swift
//  addressbook
//

import SwiftUI
import MessageUI

struct ContactMenuSettingForm: View {
	@ObservedObject var appSettings = AppSettings.shared
	@State private var selection = Set<ContactListRow.ContextMenuItemType>()

	private let types = ContactListRow.ContextMenuItemType.allCases

	var body: some View {
		List {
			Section(footer: Text(appSettings.isUnlockedPro ? L10n.ContactMenuSettingForm.Section.footerText : L10n.SettingsForm.onlyForContactsPlusPro)) {
				ForEach(types) { type in
					ContactMenuSettingFormRowView(type: type, selection: $selection) {
						appSettings.enabledContactContextMenuItemsTypes = types.filter { selection.contains($0) }
					}
				}
			}
			Section(footer: Text(L10n.ContactMenuSettingForm.OptionsSection.footerText)) {
				Toggle(L10n.ContactMenuSettingForm.OptionsSection.isContactContextMenuDisplayInline, isOn: $appSettings.isContactContextMenuDisplayInline)
			}
		}
		.disabled(!appSettings.isUnlockedPro)
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.ContactMenuSettingForm.navigationTitle)
		.onAppear(perform: refresh)
	}

	private func refresh() {
		selection = Set(appSettings.enabledContactContextMenuItemsTypes)
	}
}

#if DEBUG
struct ContactContextMenuSettingForm_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			ContactMenuSettingForm()
		}.onAppear {
			AppSettings.shared.isUnlockedPro = true
		}
	}
}
#endif
