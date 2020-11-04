//
//  CallDirectoryEntryForm.swift
//  addressbook
//

import SwiftUI

struct CallDirectoryEntryForm: View {
	@Environment(\.presentationMode) var presentationMode
	@State private var name = ""
	@State private var phoneNumberString = ""

	var formType: FormType
	var entryType: CallDirectoryEntry.EntryType

	var isFormValid: Bool {
		!name.isEmpty && phoneNumberString.count >= 4 && (Int64(phoneNumberString) != nil)
	}

	var body: some View {
		Form {
			Section(
				header: Text(L10n.CallDirectoryEntryForm.name),
				footer: nameSectionFooter
			) {
				TextField(L10n.CallDirectoryEntryForm.name, text: $name)
			}
			Section(
				header: Text(L10n.CallDirectoryEntryForm.phoneNumber),
				footer: Text(L10n.CallDirectoryEntryForm.PhoneNumberSection.footer)
			) {
				TextField(L10n.CallDirectoryEntryForm.phoneNumber, text: $phoneNumberString)
					.keyboardType(.numberPad)
			}
		}
		.navigationBarTitle(formType.navigationBarTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear {
			switch formType {
			case .add:
				return
			case .edit(let callDirectoryEntry):
				self.name = callDirectoryEntry.name ?? ""
				self.phoneNumberString = String(callDirectoryEntry.phoneNumber)
			}
		}
	}

	@ViewBuilder private var nameSectionFooter: some View {
		switch entryType {
		case .identification:
			Text(L10n.CallDirectoryEntryForm.NameSection.footer)
		case .blocking:
			EmptyView()
		}
	}

	private var cancelButton: some View {
		Button {
			presentationMode.wrappedValue.dismiss()
		} label: {
			Text(L10n.cancel)
		}
	}

	private var doneButton: some View {
		Button {
			saveCallDirectoryEntry()
			presentationMode.wrappedValue.dismiss()
		} label: {
			switch formType {
			case .add:
				Text(L10n.add)
					.bold()
			case .edit:
				Text(L10n.done)
					.bold()
			}
		}.disabled(!isFormValid)
	}

	private func saveCallDirectoryEntry() {
		guard isFormValid, let phoneNumber = Int64(phoneNumberString) else { return }

		switch formType {
		case .add:
			SharedPersistentContainerManager.shared
				.createCallDirectoryEntry(
					isBlocked: entryType.isBlocked,
					name: name,
					phoneNumber: phoneNumber
				)
		case .edit(let callDirectoryEntry):
			SharedPersistentContainerManager.shared
				.edit(callDirectoryEntry) {
					$0.isBlocked = entryType.isBlocked
					$0.name = name
					$0.phoneNumber = phoneNumber
				}
		}
	}
}

// MARK: - FormType
extension CallDirectoryEntryForm {
	enum FormType: Identifiable {
		case add
		case edit(CallDirectoryEntry)

		var navigationBarTitle: String {
			switch self {
			case .add:
				return L10n.CallDirectoryEntryForm.AddType.navigationBarTitle
			case .edit:
				return L10n.CallDirectoryEntryForm.EditType.navigationBarTitle
			}
		}

		// MARK: - Identifiable
		var id: CallDirectoryEntry? {
			switch self {
			case .add:
				return nil
			case .edit(let callDirectoryEntry):
				return callDirectoryEntry
			}
		}
	}
}
