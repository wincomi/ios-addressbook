//
//  GroupPickerForm.swift
//  addressbook
//

import SwiftUI

struct GroupPickerForm: View {
	@ObservedObject var viewModel = GroupPickerFormViewModel()
	@Binding var selection: Set<GroupListRow>

	var body: some View {
		AsyncContentView(source: viewModel) { groupListSections in
			Form {
				ForEach(groupListSections, content: sectionContent(groupListSection:))
			}.modifier(CompatibleInsetGroupedListStyle())
		}
	}
}

private extension GroupPickerForm {
	func sectionContent(groupListSection: GroupListSection) -> some View {
		Section(header: groupListSection.headerText.map(Text.init)) {
			ForEach(groupListSection.rows, id: \.self, content: rowContent(groupListRow:))
		}
	}

	func rowContent(groupListRow: GroupListRow) -> some View {
		GroupPickerFormCell(groupListRow: groupListRow, selection: $selection)
	}
}
