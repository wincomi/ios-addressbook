//
//  EditGroupsFormCell.swift
//  addressbook
//

import SwiftUI

struct EditGroupsFormCell: View {
	var groupListRow: GroupListRow
	var selection: Set<GroupListRow>
	var action: () -> Void
	
	var body: some View {
		Button(action: action) {
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
}
