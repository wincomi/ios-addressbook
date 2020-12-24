//
//  SortOrderPickerForm.swift
//  addressbook
//

import SwiftUI

struct SortOrderPickerForm: View {
	@Binding var sortOrder: AppSettings.SortOrder

	var body: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.SortOrder.title), items: AppSettings.SortOrder.allCases, selection: $sortOrder) { row, isSelected in
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

struct SortOrderPickerForm_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			SortOrderPickerForm(sortOrder: .constant(.default))
		}
	}
}
