//
//  ContactListCell.swift
//  addressbook
//

import UIKit

class ContactListCell: UITableViewCell {
	static let reuseIdentifier = "ContactListCell"

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		detailTextLabel?.textColor = .secondaryLabel

		// Fix when imageView.image == nil
		if let imageView = imageView, imageView.image != nil {
			imageView.tintColor = .secondaryLabel
			imageView.clipsToBounds = true
			imageView.contentMode = .scaleAspectFill

			let padding: CGFloat = 6
			let imageViewHeight = imageView.frame.height - padding * 2

			imageView.frame = CGRect(x: 16, y: padding, width: imageViewHeight, height: imageViewHeight)
			imageView.layer.cornerRadius = imageView.frame.size.height / 2

			if let textLabel = textLabel {
				textLabel.frame = CGRect(x: imageView.frame.minX + imageViewHeight + padding * 2, y: textLabel.frame.minY, width: textLabel.frame.width, height: textLabel.frame.height)
				if let detailTextLabel = detailTextLabel {
					detailTextLabel.frame = CGRect(x: textLabel.frame.minX, y: detailTextLabel.frame.minY, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
				}
				separatorInset = UIEdgeInsets(top: 0, left: textLabel.frame.minX, bottom: 0, right: 0)
			}
		}
	}

	func configure(with row: ContactListRow) {
		textLabel?.text = row.text
		detailTextLabel?.text = row.secondaryText
		imageView?.image = AppSettings.shared.showContactImageInContactList ? row.image : nil
	}
}
