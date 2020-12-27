//
//  LoadingState.swift
//  addressbook
//

enum LoadingState<Success, Failure: Error> {
	case idle
	case loading
	case loaded(Success)
	case failed(Failure)
}
