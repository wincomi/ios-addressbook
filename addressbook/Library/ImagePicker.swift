//
//  ImagePicker.swift
//  addressbook
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	@Environment(\.presentationMode) var presentationMode
	@Binding var image: UIImage?

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let vc = UIImagePickerController()
		vc.allowsEditing = true
		vc.delegate = context.coordinator
		return vc
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let uiImage = info[.editedImage] as? UIImage {
				parent.image = uiImage
			}

			parent.presentationMode.wrappedValue.dismiss()
		}
	}
}
