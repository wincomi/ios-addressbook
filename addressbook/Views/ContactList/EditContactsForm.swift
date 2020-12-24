//
//  EditContactsForm.swift
//  addressbook
//

import SwiftUI
import Contacts

struct EditContactsForm: View {
	let contacts: [CNContact]
	var dismissHandler: (() -> Void)

	@State private var image: UIImage?
	@State private var jobTitle = ""
	@State private var departmentName = ""
	@State private var organizationName = ""

	@State private var isDeletingImage = false
	@State private var isPresentedImagePicker = false

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text(L10n.EditContactsForm.profileImage)) {
					if let image = image {
						Image(uiImage: image)
							.resizable()
							.scaledToFit()
							.clipShape(Circle())
					}
					Button {
						isPresentedImagePicker.toggle()
					} label: {
						Text("\(L10n.EditContactsForm.selectImage)...")
					}.disabled(isDeletingImage)
					Toggle(L10n.EditContactsForm.deleteProfileImage, isOn: $isDeletingImage.onUpdate { image = nil })
				}
				Section(header: Text(L10n.EditContactsForm.jobTitle)) {
					TextField(L10n.EditContactsForm.jobTitle, text: $jobTitle)
				}
				Section(header: Text(L10n.EditContactsForm.departmentName)) {
					TextField(L10n.EditContactsForm.departmentName, text: $departmentName)
				}
				Section(header: Text(L10n.EditContactsForm.organizationName), footer: Text(L10n.EditContactsForm.Section.footer)) {
					TextField(L10n.EditContactsForm.organizationName, text: $organizationName)
				}
			}.sheet(isPresented: $isPresentedImagePicker) {
				ImagePicker(image: $image)
			}
			.navigationBarTitle(L10n.EditContactsForm.navigationTitle)
			.navigationBarItems(leading: cancelButton, trailing: doneButton)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	private var cancelButton: some View {
		Button {
			dismissHandler()
		} label: {
			Text(L10n.cancel)
		}
	}

	private var doneButton: some View {
		Button {
			do {
				try updateContacts()
				dismissHandler()
			} catch {
				print(error.localizedDescription)
			}
		} label: {
			Text(L10n.done).bold()
		}
	}

	func updateContacts() throws {
		do {
			try contacts.forEach { contact in
				try contact.update { mutableContact in
					if isDeletingImage {
						mutableContact.imageData = nil
					} else {
						if let imageData = image?.pngData() {
							mutableContact.imageData = imageData
						}
					}

					if !jobTitle.isEmpty {
						mutableContact.jobTitle = jobTitle
					}

					if !departmentName.isEmpty {
						mutableContact.departmentName = departmentName
					}

					if !organizationName.isEmpty {
						mutableContact.organizationName = organizationName
					}
				}
			}
		} catch {
			throw error
		}
	}
}
