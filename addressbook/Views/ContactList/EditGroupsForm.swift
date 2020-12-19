//
//  EditGroupsForm.swift
//  addressbook
//

import SwiftUI
import Contacts

struct EditGroupsForm: View {
	let contactToEditGroups: CNContact
	var dismissHandler: (() -> Void)

	@State private var selection = Set<GroupListRow>()
	@State private var sections = [GroupListSection]()

	@State var groupIdentifiersOfContact = Set<String>()

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text(L10n.contact), footer: Text(L10n.EditGroupsForm.ContactSection.footer)) {
					Text(ContactListRow.title(for: contactToEditGroups))
						.foregroundColor(Color(UIColor.secondaryLabel))
				}
				ForEach(sections) { section in
					Section(header: section.headerText.map { Text($0) }) {
						ForEach(section.rows) { groupListRow in
							Button {
								action(for: groupListRow)
							} label: {
								EditGroupsFormRowView(groupListRow: groupListRow, selection: $selection)
							}
						}
					}
				}
			}
			.modifier(CompatibleInsetGroupedListStyle())
			.navigationBarTitle(L10n.EditGroupsForm.navigationTitle)
			.navigationBarItems(trailing: doneButton)
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.onAppear(perform: refresh)
	}

	private func refresh() {
		do {
			self.sections = try {
				let containers = try ContactStore.shared.fetchContainers()
				let sections = try GroupListSection.makeSections(from: containers)
				return sections.filter { !$0.rows.isEmpty }
			}()

			self.selection = Set(try self.sections.reduce([]) { result, section in
				result + (try section.rows.filter { row in
					let contacts = try row.fetchContacts()
					return contacts.map(\.identifier).contains(contactToEditGroups.identifier)
				})
			})
		} catch {
			self.sections = []
			self.selection = []
		}
	}

	private func action(for groupListRow: GroupListRow) {
		guard case .group(let group) = groupListRow.type else { return }
		do {
			if selection.contains(groupListRow) {
				try ContactStore.shared.remove(contactToEditGroups, from: group)
				selection.remove(groupListRow)
			} else {
				try ContactStore.shared.add(contactToEditGroups, to: group)
				selection.insert(groupListRow)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	private var doneButton: some View {
		Button {
			dismissHandler()
		} label: {
			Text(L10n.done).bold()
		}
	}
}
