//
//  UpdateGroupForm.swift
//  addressbook
//

import SwiftUI

struct UpdateGroupForm: View {
	weak var coordinator: RootCoordinator?
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject var viewModel: UpdateGroupFormViewModel
	@State private var groupName = ""

	private var isFormValid: Bool {
		!groupName.isEmpty
	}

	var body: some View {
		Form {
			Section(header: Text(L10n.CreateGroupForm.NameSection.name).padding(.horizontal)) {
				TextField(viewModel.currentGroup.name, text: $groupName)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
						textField.becomeFirstResponder()
					}
			}
		}
		.navigationBarTitle(L10n.UpdateGroupForm.navigationTitle)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear {
			groupName = viewModel.currentGroup.name
		}
	}

	private var cancelButton: some View {
		Button(action: dismiss){
			Text(L10n.cancel)
		}
	}

	private var doneButton: some View {
		Button {
			do {
				try viewModel.updateGroup(withGroupName: groupName)
				dismiss()
			} catch {
				coordinator?.present(AlertItem(error: error))
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
