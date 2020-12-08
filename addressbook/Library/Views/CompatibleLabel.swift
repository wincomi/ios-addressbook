//
//  CompatibleLabel.swift
//  addressbook
//

import SwiftUI

struct CompatibleLabel<Title: View, Icon: View>: View {
	private let title: Title
	private let icon: Icon
	
	init<S>(_ title: S, systemImage name: String) where S: StringProtocol, Title == Text, Icon == Image {
		self.title = Text(title)
		self.icon = Image(systemName: name)
	}
	
	init(_ titleKey: LocalizedStringKey, systemImage name: String) where Title == Text, Icon == Image {
		self.title = Text(titleKey)
		self.icon = Image(systemName: name)
	}
	
	init(title: () -> Title, icon: () -> Icon) {
		self.title = title()
		self.icon = icon()
	}
	
	var body: some View {
		HStack {
			if #available(iOS 14.0, *) {
				Label(title: { title }, icon: { icon })
			} else {
				icon
					.padding(.horizontal, 4)
					.foregroundColor(.accentColor)
				title
			}
		}
	}
}

#if DEBUG
struct CompatibleLabel_Previews: PreviewProvider {
	static var previews: some View {
		CompatibleLabel(L10n.AppSettings.UserInterfaceStyle.title, systemImage: "moon")
			.previewLayout(.sizeThatFits)
	}
}
#endif
