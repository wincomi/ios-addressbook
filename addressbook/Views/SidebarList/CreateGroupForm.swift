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
				header: Text(L10n.GroupList.CreateGroupAlert.TextField.placeholder).padding(.leading),
				footer: Text(L10n.GroupList.CreateGroupAlert.message).padding(.leading)
			) {
				TextField(L10n.GroupList.CreateGroupAlert.TextField.placeholder, text: $groupName)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
						textField.becomeFirstResponder()
					}
			}
			if !viewModel.containers.isEmpty {
				Section(
					header: Text(L10n.CreateGroupForm.AccountsSection.header).padding(.leading),
					footer: Text(L10n.CreateGroupForm.AccountsSection.footer).padding(.leading)
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
		.navigationBarTitle(L10n.GroupList.CreateGroupAlert.title)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear(perform: viewModel.update)
		.onReceive(ContactStore.didChange, perform: viewModel.update)
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
			viewModel.createGroup(groupName: groupName) { error in
				if let error = error {
					coordinator?.present(AlertItem(error: error))
				} else {
					presentationMode.wrappedValue.dismiss()
				}
			}
		} label: {
			Text(L10n.GroupList.CreateGroupAlert.save)
		}.disabled(!isFormValid)
	}
}

struct CreateGroupForm_Previews: PreviewProvider {
	static var previews: some View {
		CreateGroupForm()
	}
}
