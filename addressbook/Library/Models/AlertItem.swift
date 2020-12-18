//
//  AlertItem.swift
//  COMIKit
//

import Foundation
import UIKit

public struct AlertItem: Identifiable, Hashable {
	public var id = UUID()
	public var title: String
	public var message: String?

	public init(title: String, message: String?) {
		self.title = title
		self.message = message
	}

	public init(error: Error) {
		self.title = L10n.errorAlertTitle
		self.message = error.localizedDescription
	}
}

public extension UIViewController {
	func present(_ alertItem: AlertItem, completion: (() -> Void)? = nil) {
		let alert = UIAlertController(title: alertItem.title, message: alertItem.message, preferredStyle: .alert)
		alert.addAction(.okAction())

		present(alert, animated: true, completion: completion)
	}
}
