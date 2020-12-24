//
//  UserInterfaceStylePickerForm.swift
//  addressbook
//

import SwiftUI

struct UserInterfaceStylePickerForm: View {
	@Binding var userInterfaceStyle: AppSettings.UserInterfaceStyle

	var body: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.UserInterfaceStyle.title), items: AppSettings.userInterfaceStyleAllCases, selection: $userInterfaceStyle) { userInterfaceStyle, isSelected in
			HStack {
				Text(AppSettings.localizedTitle(for: userInterfaceStyle))
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}
}

struct UserInterfaceStylePickerForm_Previews: PreviewProvider {
	static var previews: some View {
		UserInterfaceStylePickerForm(userInterfaceStyle: .constant(.unspecified))
	}
}
