//
//  EditGroupsFormRowView.swift
//  addressbook
//

import SwiftUI

struct EditGroupsFormRowView: View {
	let groupListRow: GroupListRow
	@Binding var selection: Set<GroupListRow>
	
	var body: some View {
		HStack {
			CompatibleLabel {
				Text(groupListRow.text)
					.foregroundColor(Color(UIColor.label))
			} icon: {
				Image(systemName: "folder")
					.font(.system(size: 20))
			}
			Spacer()
			if selection.contains(groupListRow) {
				Image(systemName: "checkmark")
			}
		}
	}
}
