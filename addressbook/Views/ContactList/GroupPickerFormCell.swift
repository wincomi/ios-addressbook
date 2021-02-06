//
//  GroupPickerFormCell.swift
//  addressbook
//

import SwiftUI

struct GroupPickerFormCell: View {
	var groupListRow: GroupListRow
	@Binding var selection: Set<GroupListRow>

	var body: some View {
		Button(action: action, label: label)
	}
}

private extension GroupPickerFormCell {
	func action() {
		if selection.contains(groupListRow) {
			selection.remove(groupListRow)
		} else {
			selection.insert(groupListRow)
		}
	}

	func label() -> some View {
		HStack {
			CompatibleLabel {
				Text(groupListRow.text)
					.foregroundColor(Color(UIColor.label))
			} icon: {
				image(for: groupListRow)
			}
			Spacer()
			if selection.contains(groupListRow) {
				Image(systemName: "checkmark")
			}
		}
	}

	@ViewBuilder func image(for groupListRow: GroupListRow) -> some View {
		switch groupListRow.type {
		case .allContacts:
			Image(systemName: "person.2.square.stack")
				.font(.system(size: 20))
		case .group:
			Image(systemName: "folder")
				.font(.system(size: 20))
		}
	}
}
