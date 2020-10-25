//
//  ValueCellView.swift
//  COMIKit
//

import SwiftUI

/// Cell with side-by-side value text
struct ValueCellView: View {
	let row: RowRepresentable
	let imageTintColor: UIColor?

	init(_ row: RowRepresentable, imageTintColor: UIColor? = nil) {
		self.row = row
		self.imageTintColor = imageTintColor
	}

	// MARK: -
	var body: some View {
		HStack(alignment: .center, spacing: 12) {
			if let image = row.image {
				if let tintColor = imageTintColor {
					Image(uiImage: image.colored(tintColor))
				} else {
					Image(uiImage: image)
				}
			}
			Text(row.text)
				.lineLimit(1)
				.foregroundColor(Color(UIColor.label))
			Spacer()
			if let secondaryText = row.secondaryText {
				Text(secondaryText)
					.lineLimit(1)
					.foregroundColor(Color(UIColor.secondaryLabel))
			}
		}.font(.body)
	}
}

#if DEBUG
struct ValueCellView_Previews: PreviewProvider {
	struct SampleRow_Preview: RowRepresentable {
		let text: String = "text"
		let secondaryText: String? = "secondaryText"
		let image: UIImage? = UIImage(systemName: "plus")
	}

	static var previews: some View {
		ValueCellView(SampleRow_Preview())
			.padding()
			.previewLayout(.sizeThatFits)
	}
}
#endif

extension UIImage {
	func colored(_ color: UIColor) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { context in
			color.setFill()
			draw(at: .zero)
			context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .sourceAtop)
		}
	}
}
