//
//  AsyncContentView.swift
//  addressbook
//

import SwiftUI

struct AsyncContentView<Source: LoadableObject, LoadingView: View, ErrorView: View, Content: View>: View {
	@ObservedObject var source: Source
	var loadingView: (() -> LoadingView)
	var errorView: (Source.Failure) -> ErrorView
	var content: (Source.Output) -> Content

	init(source: Source, @ViewBuilder content: @escaping ((Source.Output) -> Content)) where ErrorView == EmptyView, LoadingView == EmptyView {
		self.init(source: source, loadingView: { EmptyView() }, errorView: { _ in EmptyView() }, content: content)
	}

	init(source: Source, @ViewBuilder errorView: @escaping ((Source.Failure) -> ErrorView), @ViewBuilder content: @escaping ((Source.Output) -> Content)) where LoadingView == EmptyView {
		self.init(source: source, loadingView: { EmptyView() }, errorView: errorView, content: content)
	}

	init(source: Source, @ViewBuilder loadingView: @escaping (() -> LoadingView), @ViewBuilder errorView: @escaping ((Source.Failure) -> ErrorView), @ViewBuilder content: @escaping ((Source.Output) -> Content)) {
		self.source = source
		self.errorView = errorView
		self.loadingView = loadingView
		self.content = content
	}

	var body: some View {
		switch source.state {
		case .idle:
			Color.clear
				.onAppear(perform: source.load)
		case .loading:
			loadingView()
				.onAppear(perform: source.load)
		case .failed(let error):
			errorView(error)
				.onAppear(perform: source.load)
		case .loaded(let sections):
			content(sections)
		}
	}
}
