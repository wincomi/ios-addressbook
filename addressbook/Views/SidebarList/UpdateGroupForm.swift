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
			Section(header: Text(L10n.GroupList.CreateGroupAlert.TextField.placeholder).padding(.leading)) {
				TextField(viewModel.currentGroup.name, text: $groupName)
					.introspectTextField { textField in
						textField.clearButtonMode = .whileEditing
						textField.becomeFirstResponder()
					}
			}
		}
		.navigationBarTitle(L10n.GroupList.UpdateGroupAlert.title)
		.navigationBarItems(leading: cancelButton, trailing: doneButton)
		.onAppear {
			groupName = viewModel.currentGroup.name
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
			viewModel.updateGroup(withGroupName: groupName) { error in
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
