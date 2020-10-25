//
//  ContactMenuSettingForm.swift
//  addressbook
//

import SwiftUI
import MessageUI

struct ContactMenuSettingForm: View {
	@ObservedObject var appSettings = AppSettings.shared
	private var rows = ContactListRow.ContextMenuItemType.allCases
	@State private var selection = Set<ContactListRow.ContextMenuItemType>() {
		didSet {
			appSettings.enabledContactContextMenuItemsTypes = rows.filter { selection.contains($0) }
		}
	}

	var body: some View {
		List {
			Section(footer: Text(appSettings.isUnlockedPro ? L10n.ContactMenuSettingForm.Section.footerText : L10n.SettingsForm.onlyForContactsPlusPro)) {
				ForEach(rows) { row in
					cell(for: row)
						.disabled(!isEnabled(for: row))
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

	private func cell(for row: ContactListRow.ContextMenuItemType) -> some View {
		Button {
			if selection.contains(row) {
				selection.remove(row)
			} else {
				selection.insert(row)
			}
		} label: {
			ContactMenuSettingFormCell(contextMenuItemType: row, checked: selection.contains(row))
		}
	}

	private func isEnabled(for row: ContactListRow.ContextMenuItemType) -> Bool {
		switch row {
		case .call:
			return UIApplication.shared.canOpenURL(URL(string: "tel:")!)
		case .sendMessage:
			return MFMessageComposeViewController.canSendText()
		case .sendMail:
			return MFMailComposeViewController.canSendMail()
		default:
			return true
		}
	}
}

#if DEBUG
struct ContactContextMenuSettingForm_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			ContactMenuSettingForm()
		}
		.onAppear {
			AppSettings.shared.isUnlockedPro = true
		}
	}
}
#endif
