//
//  MessageFilterActionPickerForm.swift
//  addressbook
//

import SwiftUI

struct MessageFilterActionPickerForm: View {
	@Binding var filterAction: MessageFilter.FilterAction
	var filterActions: [MessageFilter.FilterAction] = [.junk, .promotion, .transaction]

	var body: some View {
		EnumPickerForm(
			title: Text(L10n.MessageFilterForm.action),
			items: filterActions,
			selection: $filterAction
		) { filterAction, isSelected in
			HStack {
				CompatibleLabel {
					Text(filterAction.localizedTitle)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: filterAction.systemImageName)
				}
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}
}
