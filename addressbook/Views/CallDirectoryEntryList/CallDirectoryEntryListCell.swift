//
//  CallDirectoryEntryListCell.swift
//  addressbook
//

import SwiftUI
import PhoneNumberKit

struct CallDirectoryEntryListCell: View {
	let callDirectoryEntry: CallDirectoryEntry

	var body: some View {
		HStack {
			Text(callDirectoryEntry.name ?? L10n.ContactListRow.noName)
				.foregroundColor(Color(UIColor.label))
				.lineLimit(1)
			Spacer()
			Text(phoneNumberString)
				.foregroundColor(Color(UIColor.secondaryLabel))
				.lineLimit(1)
		}
	}

	var phoneNumberString: String {
		let phoneNumberString = String(describing: callDirectoryEntry.phoneNumber)
		if let phoneNumber = try? PhoneNumberKit().parse(phoneNumberString) {
			return PhoneNumberKit().format(phoneNumber, toType: .international)
		} else {
			return String(describing: callDirectoryEntry.phoneNumber)
		}
	}
}
