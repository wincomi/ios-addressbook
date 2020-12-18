//
//  SidebarListCell.swift
//  addressbook
//

import SwiftUI

struct SidebarListCell: View {
	let groupListRow: GroupListRow
	var action: (() -> Void)

	var isDeletable: Bool {
		switch groupListRow.type {
		case .allContacts:
			return false
		case .group:
			return true
		}
	}

	var body: some View {
		NavigationButton(action: action) {
			CompatibleLabel {
				Text(groupListRow.text)
					.foregroundColor(Color(UIColor.label))
			} icon: {
				switch groupListRow.type {
				case .allContacts:
					Image(systemName: "person.2.square.stack")
						.font(.system(size: 20))
				case .group:
					Image(systemName: "folder")
						.font(.system(size: 20))
				}
			}
		}.deleteDisabled(!isDeletable)
	}
}

struct SidebarListCell_Previews: PreviewProvider {
	static var previews: some View {
		SidebarListCell(groupListRow: .allContacts()) { }
	}
}
