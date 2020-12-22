//
//  CompatibleLabel.swift
//  addressbook
//

import SwiftUI

struct CompatibleLabel<Title: View, Icon: View>: View {
	private let title: (() -> Title)
	private let icon: (() -> Icon)
	
	init<S>(_ title: S, systemImage name: String) where S: StringProtocol, Title == Text, Icon == Image {
		self.init {
			Text(title)
		} icon: {
			Image(systemName: name)
		}
	}
	
	init(_ titleKey: LocalizedStringKey, systemImage name: String) where Title == Text, Icon == Image {
		self.init {
			Text(titleKey)
		} icon: {
			Image(systemName: name)
		}
	}
	
	init(@ViewBuilder title: @escaping () -> Title, @ViewBuilder icon: @escaping () -> Icon) {
		self.title = title
		self.icon = icon
	}
	
	var body: some View {
		if #available(iOS 14.0, *) {
			Label(title: title, icon: icon)
		} else {
			HStack {
				icon()
					.padding(.horizontal, 4)
					.foregroundColor(.accentColor)
				title()
			}
		}
	}
}

struct CompatibleLabel_Previews: PreviewProvider {
	static var previews: some View {
		CompatibleLabel(L10n.AppSettings.UserInterfaceStyle.title, systemImage: "moon")
			.previewLayout(.sizeThatFits)
	}
}
