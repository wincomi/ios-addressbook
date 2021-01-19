//
//  ContactListToolbarItemsProvider.swift
//  addressbook
//

import UIKit
import MessageUI

final class ContactListToolbarItemsProvider: ToolbarItemsProvider {
	enum ToolbarItemType: String, CaseIterable {
		case action
		case sendMessage
		case sendMail
		case addToGroup
		case edit
		case delete
	}

	var actionHandler: ((UIBarButtonItem) -> Void)?
	var sendMessageHandler: ((UIBarButtonItem) -> Void)?
	var sendMailHandler: ((UIBarButtonItem) -> Void)?
	var addToGroupHandler: ((UIBarButtonItem) -> Void)?
	var editHandler: ((UIBarButtonItem) -> Void)?
	var deleteHandler: ((UIBarButtonItem) -> Void)?

	lazy var action: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up"), handler: {
			self.actionHandler?(self.action)
		})
	}()

	lazy var sendMessage: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.ContactListRow.ContextMenuItemType.sendMessage, image: UIImage(systemName: "message"), handler: {
			self.sendMessageHandler?(self.sendMessage)
		})
	}()

	lazy var sendMail: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.ContactListRow.ContextMenuItemType.sendMail, image: UIImage(systemName: "envelope"), handler: {
			self.sendMailHandler?(self.sendMail)
		})
	}()

	lazy var addToGroup: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.ContactListRow.ContextMenuItemType.addToGroup, image: UIImage(systemName: "folder.badge.plus"), handler: {
			self.addToGroupHandler?(self.sendMail)
		})
	}()

	lazy var delete: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.delete, image: UIImage(systemName: "trash"), handler: {
			self.deleteHandler?(self.delete)
		})
	}()

	lazy var edit: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.EditContactsForm.navigationTitle, image: editImage, handler: {
			self.editHandler?(self.edit)
		})
	}()

	private var editImage: UIImage? {
		if #available(iOS 14.0, *) {
			return UIImage(systemName: "rectangle.and.pencil.and.ellipsis")
		} else {
			return UIImage(systemName: "pencil.circle")
		}
	}

	// MARK: - ToolbarItemsProvider
	func toolbarItem(for type: ToolbarItemType) -> ToolbarItem? {
		switch type {
		case .action:
			return action
		case .sendMessage:
			#if DEBUG
			return sendMessage
			#else
			return MFMessageComposeViewController.canSendText() ? sendMessage : nil
			#endif
		case .sendMail:
			#if DEBUG
			return sendMail
			#else
			return MFMailComposeViewController.canSendMail() ? sendMail : nil
			#endif
		case .addToGroup:
			return addToGroup
		case .edit:
			return edit
		case .delete:
			return delete
		}
	}
}
