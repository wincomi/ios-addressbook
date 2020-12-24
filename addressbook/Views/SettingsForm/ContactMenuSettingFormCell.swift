//
//  ContactMenuSettingFormRowView.swift
//  addressbook
//

import SwiftUI
import MessageUI

struct ContactMenuSettingFormCell: View {
	let type: ContactListRow.ContextMenuItemType

	@Binding var selection: Set<ContactListRow.ContextMenuItemType>

	let action: (() -> Void)

	private var isChecked: Bool {
		selection.contains(type)
	}

	private var isEnabled: Bool {
		switch type {
		case .call:
			return UIApplication.shared.canOpenURL(URL(string: "tel:")!)
		case .sendMessage:
			return MFMessageComposeViewController.canSendText()
		case .sendMail:
			return MailComposeView.canSendMail()
		default:
			return true
		}
	}

	var body: some View {
		Button {
			if selection.contains(type) {
				selection.remove(type)
			} else {
				selection.insert(type)
			}
			
			action()
		} label: {
			HStack {
				CompatibleLabel {
					Text(type.localizedTitle)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: type.imageSystemName)
						.font(.system(size: 20))
				}
				if isChecked {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}.disabled(!isEnabled)
	}
}

struct ContactMenuSettingFormRowView_Previews: PreviewProvider {
	static var previews: some View {
		ContactMenuSettingFormCell(type: .call, selection: .constant(Set<ContactListRow.ContextMenuItemType>())) { }
	}
}
