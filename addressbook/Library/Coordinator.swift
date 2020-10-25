//
//  Coordinator.swift
//  addressbook
//

import UIKit.UIViewController

protocol Coordinator {
	associatedtype ViewController: UIViewController
	var viewController: ViewController { get set }
	func start()
}
