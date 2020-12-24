//
//  DisplayOrderPickerForm.swift
//  addressbook
//

import SwiftUI

struct DisplayOrderPickerForm: View {
	@Binding var displayOrder: AppSettings.DisplayOrder

	var body: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.DisplayOrder.title), items: AppSettings.DisplayOrder.allCases, selection: $displayOrder) { row, isSelected in
			HStack {
				Text(row.localizedTitle)
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}
}

struct DisplayOrderPickerForm_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			DisplayOrderPickerForm(displayOrder: .constant(.default))
		}
	}
}
