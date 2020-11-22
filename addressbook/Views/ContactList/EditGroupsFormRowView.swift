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
			ValueCellView(groupListRow, imageTintColor: AppSettings.shared.globalTintColor)
			Spacer()
			if selection.contains(groupListRow) {
				Image(systemName: "checkmark")
			}
		}
	}
}
