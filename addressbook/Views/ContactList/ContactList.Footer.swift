//
//  ContactList.Footer.swift
//  addressbook
//

import SwiftUI

extension ContactListViewController {
	func footerView(numberOfContacts: Int) -> UIView {
		UIHostingController(rootView: Footer(numberOfContacts: numberOfContacts)).view
	}

	struct Footer: View {
		var numberOfContacts: Int

		var body: some View {
			VStack(spacing: 6) {
				Divider()
				Text(L10n.ContactListFooterView.text(numberOfContacts))
					.foregroundColor(Color(UIColor.secondaryLabel))
					.padding()
			}
		}
	}

	struct Footer_Previews: PreviewProvider {
		static var previews: some View {
			Footer(numberOfContacts: 0)
		}
	}
}
