//
//  CallDirectoryEntryForm.swift
//  addressbook
//

import SwiftUI

struct CallDirectoryEntryForm: View {
	let formType: FormType
	let entryType: CallDirectoryEntry.EntryType

	var navigationTitle: String {
		switch formType {
		case .create:
			return L10n.CallDirectoryEntryForm.AddType.navigationTitle
		case .update:
			return L10n.CallDirectoryEntryForm.EditType.navigationTitle
		}
	}

	var isFormValid: Bool {
		!name.isEmpty && phoneNumberString.count >= 4 && (Int64(phoneNumberString) != nil)
	}

	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var viewModel = CallDirectoryEntryFormViewModel()

	@State private var name = ""
	@State private var phoneNumberString = ""

	var body: some View {
		Form {
			Section(
				header: Text(L10n.CallDirectoryEntryForm.name),
				footer: nameSectionFooter
			) {
				TextField(L10n.CallDirectoryEntryForm.name, text: $name)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
						textField.becomeFirstResponder()
					}
			}

			Section(
				header: Text(L10n.CallDirectoryEntryForm.phoneNumber),
				footer: Text(L10n.CallDirectoryEntryForm.PhoneNumberSection.footer)
			) {
				TextField(L10n.CallDirectoryEntryForm.phoneNumber, text: $phoneNumberString)
					.keyboardType(.numberPad)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
					}
			}

			switch formType {
			case .create:
				EmptyView()
			case .update(let callDirectoryEntry):
				Button {
					viewModel.remove(callDirectoryEntry)
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
		.navigationBarTitle(navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear {
			switch formType {
			case .create:
				break
			case .update(let callDirectoryEntry):
				self.name = callDirectoryEntry.name ?? ""
				self.phoneNumberString = String(callDirectoryEntry.phoneNumber)
			}
		}
	}
}

private extension CallDirectoryEntryForm {
	@ViewBuilder var nameSectionFooter: some View {
		switch entryType {
		case .identification:
			Text(L10n.CallDirectoryEntryForm.NameSection.footer)
		case .blocking:
			EmptyView()
		}
	}

	var cancelButton: some View {
		Button(action: dismiss) {
			Text(L10n.cancel)
				.fontWeight(.regular)
		}
	}

	var doneButton: some View {
		Button {
			guard isFormValid, let phoneNumber = Int64(phoneNumberString) else { return }
			switch formType {
			case .create:
				viewModel.createCallDirectoryEntry(entryType: entryType, name: name, phoneNumber: phoneNumber)
			case .update(let callDirectoryEntry):
				viewModel.update(callDirectoryEntry, entryType: entryType, name: name, phoneNumber: phoneNumber)
			}
			dismiss()
		} label: {
			switch formType {
			case .create:
				Text(L10n.add)
			case .update:
				Text(L10n.done)
			}
		}.disabled(!isFormValid)
	}

	func dismiss() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		presentationMode.wrappedValue.dismiss()
	}
}

// MARK: - FormType
extension CallDirectoryEntryForm {
	enum FormType: Hashable, Identifiable {
		case create
		case update(CallDirectoryEntry)

		// MARK: - Identifiable
		var id: Int {
			hashValue
		}
	}
}
