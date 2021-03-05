//
//  MessageFilterForm.swift
//  addressbook
//

import SwiftUI
import IdentityLookup

struct MessageFilterForm: View {
	@Environment(\.presentationMode) var presentationMode

	private var isEnabled: Bool = true
	@State private var filterType: Int = 0
	@State private var filterText: String = ""
	@State private var isCaseSensitive: Bool = false
	private var filterCondition: Int = 0
	@State private var filterAction: ILMessageFilterAction = .junk
	private var filterActionsAllCases: [ILMessageFilterAction] = [.junk]

	var body: some View {
		Form {
			Section {
				Picker("Type", selection: $filterType) {

				}.pickerStyle(DefaultPickerStyle())
			}
			Section(header: Text("Text")) {
				TextField("Text", text: $filterText)
				Toggle("Case Sensitive", isOn: $isCaseSensitive)
			}
			Section {
				Picker("Action", selection: $filterAction) {

				}.pickerStyle(DefaultPickerStyle())
			}
		}
		.navigationBarTitle("Add Filter")
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
	}
}

private extension MessageFilterForm {
	var doneButton: some View {
		Button {
			// ...
			dismiss()
		} label: {
			Text(L10n.done)
		}
	}

	var cancelButton: some View {
		Button(action: dismiss) {
			Text(L10n.cancel)
				.fontWeight(.regular)
		}
	}

	func dismiss() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		presentationMode.wrappedValue.dismiss()
	}
}

struct MessageFilterForm_Previews: PreviewProvider {
	static var previews: some View {
		MessageFilterForm()
	}
}
