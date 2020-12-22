//
//  CircleColorView.swift
//  addressbook
//

import SwiftUI

struct CircleColorView: View {
	@Binding var showBorder: Bool
	let buttonColor: Color
	let backgroundColor: Color
	let borderColor: Color

	var body: some View {
		ZStack {
			if showBorder {
				Circle()
					.fill(borderColor)
			}
			Circle()
				.fill(backgroundColor)
				.padding(2)
			Circle()
				.fill(buttonColor)
				.padding(4)
		}
	}
}

struct CircleColorView_Previews: PreviewProvider {
	static var previews: some View {
		CircleColorView(showBorder: .constant(true), buttonColor: .blue, backgroundColor: .white, borderColor: .secondary)
			.previewLayout(.fixed(width: 64, height: 64))
	}
}
