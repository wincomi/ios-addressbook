//
//  NavigationButton.swift
//  addressbook
//

import SwiftUI

struct NavigationButton<Label: View>: View {
	let action: (() -> Void)
	let label: (() -> Label)

	var body: some View {
		Button(action: action) {
			HStack {
				label()
				Spacer()
				Image(systemName: "chevron.right")
					.font(.system(size: 13, weight: .bold))
					.foregroundColor(Color(UIColor.tertiaryLabel))
			}
		}
	}
}

struct NavigationButton_Previews: PreviewProvider {
	static var previews: some View {
		NavigationButton {

		} label: {
			Text("Navigation Button")
		}
	}
}
