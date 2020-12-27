//
//  LoadableObject.swift
//  addressbook
//

import SwiftUI

protocol LoadableObject: ObservableObject {
	associatedtype Output
	associatedtype Failure: Error
	var state: LoadingState<Output, Failure> { get }
	func load()
}
