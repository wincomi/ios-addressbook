//
//  AddToGroupForm.swift
//  addressbook
//

import SwiftUI
import Contacts

struct AddToGroupForm: View {
	/// Contacts to add to group
	var contacts: [CNContact]

	/// GroupListRows to add contacts
	@State private var selection = Set<GroupListRow>()

	var dismissHandler: (() -> Void)

	var body: some View {
		GroupPickerForm(selection: $selection)
			.navigationBarTitle(Text(L10n.ContactListRow.ContextMenuItemType.addToGroup))
			.navigationBarItems(leading: cancelButton, trailing: addButton.disabled(selection.isEmpty))
	}
}

private extension AddToGroupForm {
	var cancelButton: some View {
		Button(action: dismissHandler) {
			Text(L10n.cancel)
				.fontWeight(.regular)
		}
	}

	var addButton: some View {
		Button(action: addButtonAction) {
			Text(L10n.add)
		}
	}

	func addButtonAction() {
		selection.compactMap(group(from:)).forEach { group in
			do {
				try add(contacts, to: group)
			} catch {
				print(error)
			}
		}
		dismissHandler()
	}

	func group(from groupListRow: GroupListRow) -> CNGroup? {
		switch groupListRow.type {
		case .allContacts:
			return nil
		case .group(let group):
			return group
		}
	}

	func add(_ contacts: [CNContact], to group: CNGroup) throws {
		do {
			try contacts.forEach { contact in
				try ContactStore.shared.add(contact, to: group)
			}
		} catch {
			throw error
		}
	}
}
