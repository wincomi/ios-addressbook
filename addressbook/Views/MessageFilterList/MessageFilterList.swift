//
//  MessageFilterList.swift
//  addressbook
//

import SwiftUI

struct MessageFilterList: View {
	@ObservedObject var viewModel: MessageFilterListViewModel
	let didChange = StorageController.didChange
	@State private var isFormPresented = false

	var body: some View {
		AsyncContentView(source: viewModel, content: contentView(messageFilters:))
			.navigationBarTitle(L10n.MessageFilterList.navigationTitle)
			.navigationBarItems(trailing: createButton)
			.onReceive(didChange, perform: viewModel.load)
			.sheet(isPresented: $isFormPresented) {
				NavigationView {
					MessageFilterForm()
				}.navigationViewStyle(StackNavigationViewStyle())
			}
	}
}

private extension MessageFilterList {
	@ViewBuilder func contentView(messageFilters: [MessageFilter]) -> some View {
		if messageFilters.isEmpty {
			EmptyDataView(
				title: L10n.MessageFilterList.EmptyDataView.title,
				description: L10n.MessageFilterList.EmptyDataView.description
			)
		} else {
			List(messageFilters, id: \.self, rowContent: rowContent(messageFilter:))
				.modifier(CompatibleInsetGroupedListStyle())
		}
	}

	func rowContent(messageFilter: MessageFilter) -> some View {
		CompatibleLabel {
			Text(messageFilter.filterText)
		} icon: {
			Image(systemName: "xmark.bin")
		}
	}

	var createButton: some View {
		Button {
			isFormPresented = true
		} label: {
			Image(systemName: "plus")
				.font(.system(size: 20))
		}
	}
}

struct MessageFilterList_Previews: PreviewProvider {
	static var previews: some View {
		MessageFilterList(viewModel: .init())
	}
}
