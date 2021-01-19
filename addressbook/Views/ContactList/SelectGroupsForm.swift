//
//  SelectGroupForm.swift
//  addressbook
//

import SwiftUI

struct SelectGroupsForm: View {
	var navigationTitle = L10n.ContactListRow.ContextMenuItemType.addToGroup
	var doneButtonTitle = L10n.add
	var dismissHandler: ((Set<GroupListRow>?) -> Void)

	@State private var sections = [GroupListSection]()
	@State private var selection = Set<GroupListRow>()

	var body: some View {
		NavigationView {
			Form {
				ForEach(sections) { section in
					Section(header: section.headerText.map { Text($0).padding(.horizontal) }) {
						ForEach(section.rows) { row in
							cell(for: row)
						}
					}
				}
			}
			.modifier(CompatibleInsetGroupedListStyle())
			.navigationBarTitle(navigationTitle)
			.navigationBarItems(leading: dismissButton, trailing: doneButton)
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.onAppear(perform: refresh)
	}

	private func refresh() {
		do {
			let containers = try ContactStore.shared.fetchContainers()
			let sections = try GroupListSection.makeSections(from: containers)
			self.sections = sections.filter { !$0.rows.isEmpty }
		} catch {
			self.sections = []
		}
	}

	private var dismissButton: some View {
		Button {
			dismissHandler(nil)
		} label: {
			Text(L10n.cancel)
				.fontWeight(.regular)
		}
	}

	private var doneButton: some View {
		Button {
			dismissHandler(selection)
		} label: {
			Text(doneButtonTitle)
		}.disabled(selection.isEmpty)
	}

	private func cell(for groupListRow: GroupListRow) -> some View {
		Button {
			if selection.contains(groupListRow) {
				selection.remove(groupListRow)
			} else {
				selection.insert(groupListRow)
			}
		} label: {
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
