//
//  ContactListFooterView.swift
//  addressbook
//

import SwiftUI

struct ContactListFooterView: View {
	static func uiView(numberOfContacts: Int) -> UIView {
		UIHostingController(rootView: ContactListFooterView(numberOfContacts: numberOfContacts)).view
	}

	let numberOfContacts: Int

	var body: some View {
		VStack(spacing: 0) {
			Divider()
			Text(L10n.ContactListFooterView.text(numberOfContacts))
				.foregroundColor(Color(UIColor.secondaryLabel))
				.padding()
		}
	}
}

struct ContactListFooterView_Previews: PreviewProvider {
	static var previews: some View {
		ContactListFooterView(numberOfContacts: 0)
	}
}

