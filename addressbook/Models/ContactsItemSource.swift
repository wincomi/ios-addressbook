//
//  ContactsItemSource.swift
//  addressbook
//

import UIKit
import Contacts
import LinkPresentation

enum ContactsItemSourceError: Error, LocalizedError {
	case contactIsEmpty
	case vCardSerializationFailed
	case noCachesDirectory
	// case dataCannotBeWritten
	case unknown
}

final class ContactsItemSource: NSObject {
	let contacts: [CNContact]
	private let fileURL: URL

	init(_ contacts: [CNContact]) throws {
		self.contacts = contacts
		self.fileURL = try ContactsItemSource.fileURL(for: contacts)
	}

	static func fileURL(for contacts: [CNContact]) throws -> URL {
		guard contacts.count > 0 else {
			throw ContactsItemSourceError.contactIsEmpty
		}

		do {
			guard let data = try? CNContactVCardSerialization.data(with: contacts) else {
				throw ContactsItemSourceError.vCardSerializationFailed
			}

			guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
				throw ContactsItemSourceError.noCachesDirectory
			}

			let fileURL = directoryURL.appendingPathComponent(fileName(for: contacts)).appendingPathExtension("vcf")

			try data.write(to: fileURL, options: .atomicWrite)

			return fileURL
		} catch {
			throw ContactsItemSourceError.unknown
		}
	}

	private static func fileName(for contacts: [CNContact]) -> String {
		var fileName = L10n.contacts

		if let contact = contacts.first, contacts.count == 1 {
			var invalidCharacters = CharacterSet(charactersIn: ":/")
			invalidCharacters.formUnion(.newlines)
			invalidCharacters.formUnion(.illegalCharacters)
			invalidCharacters.formUnion(.controlCharacters)

			fileName = ContactListRow.title(for: contact).components(separatedBy: invalidCharacters).joined(separator: " ")
		}

		return fileName
	}
}

// MARK: - UIActivityItemSources
extension ContactsItemSource: UIActivityItemSource {
	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		return fileURL
	}

	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		return fileURL
	}

	func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
		let metadata = LPLinkMetadata()
		if let contact = contacts.first, contacts.count == 1 {
			metadata.title = ContactListRow(contact).text
			if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
				metadata.iconProvider = NSItemProvider(object: image)
			}
		} else {
			metadata.title = L10n.ContactsItemSource.title(contacts.count)
		}
		return metadata
	}
}
