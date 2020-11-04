//
//  CallDirectoryEntryCell.swift
//  addressbook
//

import SwiftUI

struct CallDirectoryEntryCell: View {
	let callDirectoryEntry: CallDirectoryEntry

	var body: some View {
		HStack {
			Text(callDirectoryEntry.name ?? L10n.ContactListRow.noName)
				.foregroundColor(Color(UIColor.label))
			Spacer()
			Text(String(describing: callDirectoryEntry.phoneNumber))
				.foregroundColor(Color(UIColor.secondaryLabel))
		}
	}
}
