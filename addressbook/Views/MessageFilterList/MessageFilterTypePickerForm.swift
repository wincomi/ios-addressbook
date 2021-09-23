//
//  MessageFilterTypePickerForm.swift
//  addressbook
//

import SwiftUI

struct MessageFilterTypePickerForm: View {
	@Binding var filterType: MessageFilter.FilterType
	var filterTypes: [MessageFilter.FilterType] = [.any, .messageBody, .sender]

	var body: some View {
		EnumPickerForm(
			title: Text(L10n.MessageFilterForm.type),
			items: filterTypes,
			selection: $filterType
		) { filterType, isSelected in
			HStack {
				Image(systemName: filterType.systemImageName)
					.padding(.horizontal, 4)
					.foregroundColor(.accentColor)
				Text(filterType.localizedTitle)
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}.padding(.vertical, 4)
		}
	}
}
