//
//  MessageFilterForm.swift
//  addressbook
//

import SwiftUI
import IdentityLookup

struct MessageFilterForm: View {
	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel = MessageFilterFormViewModel()

	@State private var isEnabled: Bool = true
	@State private var filterType: MessageFilter.FilterType = .any
	@State private var filterText: String = ""
	@State private var isCaseSensitive: Bool = false
	@State private var filterAction: MessageFilter.FilterAction = .junk

	var body: some View {
		Form {
			Section(header: Text(L10n.MessageFilterForm.type).padding(.horizontal)) {
				Picker(L10n.MessageFilterForm.type, selection: $filterType) {
					ForEach(MessageFilter.FilterType.allCases, id: \.self) { filterType in
						Text("\(filterType.rawValue)")
					}
				}.pickerStyle(DefaultPickerStyle())
			}
			Section(header: Text(L10n.MessageFilterForm.text).padding(.horizontal)) {
				TextField(L10n.MessageFilterForm.text, text: $filterText)
				Toggle(L10n.MessageFilterForm.caseSensitive, isOn: $isCaseSensitive)
			}
			Section(header: Text(L10n.MessageFilterForm.action).padding(.horizontal)) {
				Picker(L10n.MessageFilterForm.action, selection: $filterAction) {
					ForEach(MessageFilter.FilterAction.allCases, id: \.self) { filterAction in
						Text("\(filterAction.rawValue)")
					}
				}.pickerStyle(DefaultPickerStyle())
			}
		}
		.navigationBarTitle(L10n.MessageFilterForm.navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton.disabled(!isFormValid))
	}
}

private extension MessageFilterForm {
	var isFormValid: Bool {
		!filterText.isEmpty
	}

	var doneButton: some View {
		Button {
			viewModel.createMessageFilter(type: filterType, text: filterText, isCaseSensitive: isCaseSensitive, action: filterAction)
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
