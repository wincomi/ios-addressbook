//
//  EditGroupsForm.swift
//  addressbook
//

import SwiftUI
import Contacts

struct EditGroupsForm: View {
	@ObservedObject var viewModel: EditGroupsFormViewModel
	@State private var selection = Set<GroupListRow>()
	@State private var sections = [GroupListSection]()
	var dismissHandler: (() -> Void)

	var body: some View {
		Form {
			Section(
				header: Text(L10n.contact).padding(.horizontal),
				footer: Text(L10n.EditGroupsForm.ContactSection.footer).padding(.horizontal)
			) {
				Text(ContactListRow.title(for: viewModel.contact))
					.foregroundColor(Color(UIColor.secondaryLabel))
			}
			AsyncContentView(source: viewModel) { sections in
				ForEach(sections, content: sectionContent(groupListSection:))
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.EditGroupsForm.navigationTitle)
		.navigationBarItems(trailing: doneButton)
		.onAppear(perform: viewModel.fetchSelection)
	}
}

private extension EditGroupsForm {
	func sectionContent(groupListSection: GroupListSection) -> some View {
		Section(header: groupListSection.headerText.map { Text($0).padding(.horizontal) }) {
			ForEach(groupListSection.rows, content: rowContent(groupListRow:))
		}
	}

	func rowContent(groupListRow: GroupListRow) -> some View {
		EditGroupsFormCell(groupListRow: groupListRow, selection: viewModel.selection) {
			do {
				if viewModel.selection.contains(groupListRow) {
					try viewModel.removeContact(from: groupListRow)
				} else {
					try viewModel.addContact(to: groupListRow)
				}
			} catch {
				print(error)
			}
		}
	}

	var doneButton: some View {
		Button(action: dismissHandler) {
			Text(L10n.done)
		}
	}
}
