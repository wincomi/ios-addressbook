//
//  MessageFilterForm.swift
//  addressbook
//

import SwiftUI
import IdentityLookup

struct MessageFilterForm: View {
	var formType: FormType

	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel = MessageFilterFormViewModel()

	@State private var isEnabled: Bool = true
	@State private var filterType: MessageFilter.FilterType = .any
	@State private var filterText: String = ""
	@State private var isCaseSensitive: Bool = false
	@State private var filterAction: MessageFilter.FilterAction = .junk

	@State private var isAppeared: Bool = false

	var body: some View {
		Form {
			Section(
				header: Text(L10n.MessageFilterForm.text),
				footer: Text(L10n.MessageFilterForm.TextSection.footer)
			) {
				TextField(L10n.MessageFilterForm.text, text: $filterText)
				CompatibleLabel {
					Toggle(L10n.MessageFilterForm.caseSensitive, isOn: $isCaseSensitive)
				} icon: {
					Image(systemName: "textformat")
				}
			}
			if #available(iOS 14.0, *) {
				Section(
					header: Text(L10n.MessageFilterForm.action),
					footer: Text(L10n.MessageFilterForm.ActionSection.footer)
				) {
					NavigationLink(destination: MessageFilterActionPickerForm(filterAction: $filterAction)) {
						HStack {
							CompatibleLabel {
								Text(filterAction.localizedTitle)
									.foregroundColor(Color(UIColor.label))
							} icon: {
								Image(systemName: filterAction.systemImageName)
							}
							if case .junk = filterAction {
								Spacer()
								Image(systemName: "bell.slash.fill")
									.foregroundColor(Color(.systemRed))
									.font(.caption)
							}
						}
					}
				}
			}
		}
		.navigationBarTitle(navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton.disabled(!isFormValid))
		.onAppear {
			guard !isAppeared else { return }

			switch formType {
			case .create:
				break
			case .update(let messageFilter):
				filterType = messageFilter.type
				filterText = messageFilter.filterText
				isCaseSensitive = messageFilter.isCaseSensitive
				filterAction = messageFilter.action
			}

			isAppeared = true
		}
	}
}

private extension MessageFilterForm {
	var isFormValid: Bool {
		!filterText.isEmpty
	}

	var doneButton: some View {
		Button {
			guard isFormValid else { return }
			switch formType {
			case .create:
				viewModel.createMessageFilter(type: filterType, text: filterText, isCaseSensitive: isCaseSensitive, action: filterAction)
			case .update(let messageFilter):
				viewModel.update(messageFilter, type: filterType, text: filterText, isCaseSensitive: isCaseSensitive, action: filterAction)
			}
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

private extension MessageFilterForm {
	var navigationTitle: String {
		switch formType {
		case .create:
			return L10n.MessageFilterForm.CreateType.navigationTitle
		case .update:
			return L10n.MessageFilterForm.UpdateType.navigationTitle
		}
	}
}

struct MessageFilterForm_Previews: PreviewProvider {
	static var previews: some View {
		MessageFilterForm(formType: .create)
	}
}

// MARK: - FormType
extension MessageFilterForm {
	enum FormType: Hashable, Identifiable {
		case create
		case update(MessageFilter)

		// MARK: - Identifiable
		var id: Int {
			hashValue
		}
	}
}
