//
//  ContactMenuSettingFormCell.swift
//  addressbook
//

import SwiftUI

struct ContactMenuSettingFormCell: View {
	let contextMenuItemType: ContactListRow.ContextMenuItemType
	let checked: Bool

	var body: some View {
		HStack {
			CompatibleLabel {
				Text(contextMenuItemType.localizedTitle)
					.foregroundColor(Color(UIColor.label))
			} icon: {
				Image(systemName: contextMenuItemType.imageSystemName)
					.font(.system(size: 20))
			}
			if checked {
				Spacer()
				Image(systemName: "checkmark")
			}
		}
	}
}
