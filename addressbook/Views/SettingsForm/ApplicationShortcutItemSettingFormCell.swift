//
//  ApplicationShortcutItemSettingFormCell.swift
//  addressbook
//

import SwiftUI

struct ApplicationShortcutItemSettingFormCell: View {
	enum RowType {
		case `default`
		case add
	}
	
	let applicationShortcutItem: ApplicationShortcutItem
	let type: RowType
	let addAction: (() -> Void)?

	init(applicationShortcutItem: ApplicationShortcutItem, type: RowType = .default, addAction: (() -> Void)? = nil) {
		self.applicationShortcutItem = applicationShortcutItem
		self.type = type
		self.addAction = addAction
	}

	var body: some View {
		switch type {
		case .default:
			ValueCellView(applicationShortcutItem, imageTintColor: AppSettings.shared.globalTintColor)
		case .add:
			Button {
				addAction?()
			} label: {
				HStack(spacing: 12) {
					Image(systemName: "plus.circle.fill")
						.font(.system(size: 24))
						.foregroundColor(.green)
					Text(applicationShortcutItem.localizedTitle)
						.foregroundColor(Color(UIColor.label))
				}
			}.buttonStyle(BorderlessButtonStyle())
		}
	}
}

struct ApplicationShortcutItemSettingFormRowView_Previews: PreviewProvider {
	static var previews: some View {
		ApplicationShortcutItemSettingFormCell(applicationShortcutItem: .addContact)
	}
}
