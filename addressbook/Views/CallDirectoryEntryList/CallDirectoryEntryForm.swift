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
			if case .edit(let callDirectoryEntry) = formType {
				Button {
					StorageController.shared.remove(callDirectoryEntry)
					presentationMode.wrappedValue.dismiss()
				} label: {
					HStack {
						Spacer()
						Text(L10n.delete)
							.foregroundColor(Color(UIColor.systemRed))
						Spacer()
					}
				}
			}
		}
		.navigationBarTitle(formType.navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear {
			switch formType {
			case .add:
				break
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
			StorageController.shared
				.createCallDirectoryEntry(
					isBlocked: entryType.isBlocked,
					name: name,
					phoneNumber: phoneNumber
				)
		case .edit(let callDirectoryEntry):
			StorageController.shared
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
	enum FormType: Hashable, Identifiable {
		case add
		case edit(CallDirectoryEntry)

		var navigationTitle: String {
			switch self {
			case .add:
				return L10n.CallDirectoryEntryForm.AddType.navigationTitle
			case .edit:
				return L10n.CallDirectoryEntryForm.EditType.navigationTitle
			}
		}

		// MARK: - Identifiable
		var id: Int {
			hashValue
		}
	}
}
