//
//  MessageFilterList.swift
//  addressbook
//

import SwiftUI

struct MessageFilterList: View {
	@ObservedObject var viewModel: MessageFilterListViewModel
	@State private var isFormPresented = false

	var body: some View {
		AsyncContentView(source: viewModel, content: contentView(messageFilters:))
			.navigationBarTitle("SMS Filter")
			.navigationBarItems(trailing: createButton)
			.sheet(isPresented: $isFormPresented) {
				NavigationView {
					MessageFilterForm()
				}.navigationViewStyle(StackNavigationViewStyle())
			}
	}
}

private extension MessageFilterList {
	func contentView(messageFilters: [String]) -> some View {
		List(messageFilters, id: \.self, rowContent: rowContent(messageFilter:))
			.modifier(CompatibleInsetGroupedListStyle())
	}

	func rowContent(messageFilter: String) -> some View {
		CompatibleLabel {
			Text(messageFilter)
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
