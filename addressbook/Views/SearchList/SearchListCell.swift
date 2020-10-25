//
//  SearchListCell.swift
//  addressbook
//

import UIKit

class SearchListCell: ContactListCell {
	func configure(with row: SearchListRow) {
		super.configure(with: row.contactListRow)

		if let textLabel = textLabel {
			guard case .name = row.matchingType else { return }

			let attributedText = NSMutableAttributedString(string: row.text)

			let range = NSRange(location: 0, length: row.text.count)
			guard let regex = try? NSRegularExpression(pattern: row.searchText, options: .caseInsensitive) else { return }

			regex.enumerateMatches(in: row.text, options: .init(), range: range) { textCheckingResult, _, _ in
				guard let range = textCheckingResult?.range else { return }
				attributedText.addAttributes([.font : UIFont.boldSystemFont(ofSize: textLabel.font.pointSize)], range: range)
			}

			textLabel.attributedText = attributedText
		}
		if let detailTextLabel = detailTextLabel {
			detailTextLabel.text = row.secondaryText
		}
	}
}
