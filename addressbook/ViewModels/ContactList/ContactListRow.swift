//
//  ContactListRow.swift
//  addressbook
//

import UIKit
import Contacts
import MobileCoreServices

struct ContactListRow: RowRepresentable, Identifiable, Hashable {
	static func title(for contact: CNContact) -> String {
		if AppSettings.shared.preferNicknames, !contact.nickname.isEmpty {
			return contact.nickname
		}

		switch AppSettings.shared.displayOrder {
		case .default:
			return CNContactFormatter.string(from: contact, style: .fullName) ?? L10n.ContactListRow.noName
		case .givenNameFirst:
			let delimiter = CNContactFormatter.delimiter(for: contact)
			let nameArray = [contact.givenName, contact.familyName]
			return nameArray.joined(separator: delimiter)
		case .familyNameFirst:
			let delimiter = CNContactFormatter.delimiter(for: contact)
			let nameArray = [contact.familyName, contact.givenName]
			return nameArray.joined(separator: delimiter)
		}
	}

	let contact: CNContact

	var sortingString: String {
		if AppSettings.shared.preferNicknames, !contact.nickname.isEmpty {
			return contact.nickname
		}

		switch AppSettings.shared.sortOrder {
		case .default:
			return text
		case .givenName:
			return !contact.givenName.isEmpty ? contact.givenName : text
		case .familyName:
			return !contact.familyName.isEmpty ? contact.familyName : text
		}
	}

	// MARK: - RowRepresentable
	let text: String
	let secondaryText: String?
	let image: UIImage?

	// MARK: - Identifiable
	let id: String

	// MARK: - Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	// MARK: - Initialization
	init(_ contact: CNContact) {
		self.contact = contact
		self.text = ContactListRow.title(for: contact)
		self.secondaryText = nil
		self.image = {
			if contact.imageDataAvailable, let imageData = contact.thumbnailImageData {
				return UIImage(data: imageData)
			} else {
				return UIImage(systemName: "person.crop.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 64))
			}
		}()
		self.id = contact.identifier
	}

	init?(contactIdentifier: String) {
		guard let contacts = try? ContactStore.shared.fetchContacts(withIdentifier: [contactIdentifier]),
			  let contact = contacts.first else { return nil }
		self.init(contact)
	}

	// MARK: - Making UIDragItems
	func dragItems() -> [UIDragItem]? {
		let itemProvider = NSItemProvider(object: contact)

		if let data = try? CNContactVCardSerialization.data(with: [contact]) {
			itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeVCard as String, visibility: .all) { completion in
				completion(data, nil)
				return nil
			}
		}

		return [UIDragItem(itemProvider: itemProvider)]
	}
}
