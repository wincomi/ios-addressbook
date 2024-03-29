//
//  MessageFilterForm.swift
//  addressbook
//

import SwiftUI
import IdentityLookup

struct MessageFilterForm: View {
	let formType: FormType

	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel = MessageFilterFormViewModel()

	// @State private var isFilterEnabled: Bool = true
	@State private var filterType: MessageFilter.FilterType = .any
	@State private var filterText: String = ""
	@State private var isCaseSensitive: Bool = false
	@State private var filterAction: MessageFilter.FilterAction = .junk

	/// View를 새로 불러올 때 formType이 .update일 경우 정보를 덮어씌우는 문제를 해결하기 위한 변수
	@State private var isAppeared: Bool = false

	var body: some View {
		Form {
			Section(
				header: Text(L10n.MessageFilterForm.text),
				footer: Text(L10n.MessageFilterForm.TextSection.footer)
			) {
				TextField(L10n.MessageFilterForm.TextSection.TextField.prompt, text: $filterText)
				CompatibleLabel {
					Toggle(L10n.MessageFilterForm.caseSensitive, isOn: $isCaseSensitive)
				} icon: {
					Image(systemName: "textformat")
				}
			}

			Section(
				header: Text(L10n.MessageFilterForm.type),
				footer: Text(L10n.MessageFilterForm.TypeSection.footer)
			) {
				NavigationLink(destination: MessageFilterTypePickerForm(filterType: $filterType)) {
					HStack {
						Image(systemName: filterType.systemImageName)
							.padding(.horizontal, 4)
							.foregroundColor(.accentColor)
						Text(filterType.localizedTitle)
					}.padding(.vertical, 4)
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

			if case .update(let messageFilter) = formType {
				DispatchQueue.main.async {
					filterType = messageFilter.type
					filterText = messageFilter.filterText
					isCaseSensitive = messageFilter.isCaseSensitive
					filterAction = messageFilter.action
				}
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
				.fontWeight(.bold)
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
