//
//  CallDirectoryEntryListCell.swift
//  addressbook
//

import SwiftUI

struct CallDirectoryEntryListCell: View {
	let callDirectoryEntry: CallDirectoryEntry

	var body: some View {
		HStack {
			Text(callDirectoryEntry.name ?? L10n.ContactListRow.noName)
				.foregroundColor(Color(UIColor.label))
				.lineLimit(1)
			Spacer()
			Text(String(describing: callDirectoryEntry.phoneNumber))
				.foregroundColor(Color(UIColor.secondaryLabel))
				.lineLimit(1)
		}
	}
}
