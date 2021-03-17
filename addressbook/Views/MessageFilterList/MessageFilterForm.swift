//
//  MessageFilterForm.swift
//  addressbook
//

import SwiftUI
import IdentityLookup

struct MessageFilterForm: View {
	@Environment(\.presentationMode) var presentationMode

	@State private var isEnabled: Bool = true
	@State private var filterType: MessageFilter.FilterType = .any
	@State private var filterText: String = ""
	@State private var isCaseSensitive: Bool = false
	@State private var filterAction: MessageFilter.FilterAction = .junk

	var body: some View {
		Form {
			Section(header: Text("Type").padding(.horizontal)) {
				Picker("Type", selection: $filterType) {
					ForEach(MessageFilter.FilterType.allCases, id: \.self) { filterType in
						Text("\(filterType.rawValue)")
					}
				}.pickerStyle(DefaultPickerStyle())
			}
			Section(header: Text("Text").padding(.horizontal)) {
				TextField("Text", text: $filterText)
				Toggle("Case Sensitive", isOn: $isCaseSensitive)
			}
			Section(header: Text("Action").padding(.horizontal)) {
				Picker("Action", selection: $filterAction) {
					ForEach(MessageFilter.FilterAction.allCases, id: \.self) { filterAction in
						Text("\(filterAction.rawValue)")
					}
				}.pickerStyle(DefaultPickerStyle())
			}
		}
		.navigationBarTitle("Add Filter")
		.navigationBarItems(leading: cancelButton, trailing: doneButton.disabled(!isFormValid))
	}
}

private extension MessageFilterForm {
	var isFormValid: Bool {
		!filterText.isEmpty
	}
	
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
