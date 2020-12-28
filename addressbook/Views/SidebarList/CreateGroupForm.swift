//
//  CreateGroupForm.swift
//  addressbook
//

import SwiftUI
import Contacts
import Introspect

struct CreateGroupForm: View {
	weak var coordinator: RootCoordinator?
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject var viewModel = CreateGroupFormViewModel()
	@State private var groupName = ""

	private var isFormValid: Bool {
		!groupName.isEmpty && (viewModel.selectedContainer != nil)
	}

	var body: some View {
		Form {
			Section(
				header: Text(L10n.CreateGroupForm.NameSection.name).padding(.horizontal),
				footer: Text(L10n.CreateGroupForm.NameSection.footer).padding(.horizontal)
			) {
				TextField(L10n.CreateGroupForm.NameSection.name, text: $groupName)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
						textField.becomeFirstResponder()
					}
			}
			if !viewModel.containers.isEmpty {
				Section(
					header: Text(L10n.CreateGroupForm.AccountsSection.header).padding(.horizontal),
					footer: Text(L10n.CreateGroupForm.AccountsSection.footer).padding(.horizontal)
				) {
					ForEach(viewModel.containers, id: \.identifier) { container in
						Button {
							viewModel.selectedContainer = container
						} label: {
							CompatibleLabel {
								HStack {
									Text(container.displayName)
										.foregroundColor(Color(UIColor.label))
									if let identifier = viewModel.selectedContainer?.identifier, container.identifier == identifier {
										Spacer()
										Image(systemName: "checkmark")
									}
								}
							} icon: {
								Image(systemName: "person.crop.square")
									.font(.system(size: 20))
							}
						}
					}
				}
			}
		}
		.navigationBarTitle(L10n.CreateGroupForm.navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear(perform: viewModel.update)
		.onReceive(ContactStore.didChange, perform: viewModel.update)
	}

	private var cancelButton: some View {
		Button {
			dismiss()
		} label: {
			Text(L10n.cancel)
		}
	}

	private var doneButton: some View {
		Button {
			viewModel.createGroup(groupName: groupName) { error in
				if let error = error {
					coordinator?.present(AlertItem(error: error))
				} else {
					dismiss()
				}
			}
		} label: {
			Text(L10n.save)
		}.disabled(!isFormValid)
	}

	private func dismiss() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
		presentationMode.wrappedValue.dismiss()
	}
}

struct CreateGroupForm_Previews: PreviewProvider {
	static var previews: some View {
		CreateGroupForm()
	}
}
