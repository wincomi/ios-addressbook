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
		) { fitlerType, isSelected in
			HStack {
				CompatibleLabel {
					Text(fitlerType.localizedTitle)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: fitlerType.systemImageName)
				}
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}
}
