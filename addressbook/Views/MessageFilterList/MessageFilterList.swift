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
			emptyView
		} else {
			List {
				ForEach(messageFilters) { messageFilter in
					rowContent(messageFilter: messageFilter)
				}.onDelete(perform: delete(at:))
			}.modifier(CompatibleInsetGroupedListStyle())
		}
	}

	func rowContent(messageFilter: MessageFilter) -> some View {
		Button {
			
		} label: {
			CompatibleLabel {
				Text(messageFilter.filterText)
					.foregroundColor(Color(.label))
			} icon: {
				Image(systemName: "xmark.bin")
			}
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

	var emptyView: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.edgesIgnoringSafeArea(.all)
			EmptyDataView(
				title: L10n.MessageFilterList.EmptyDataView.title,
				description: L10n.MessageFilterList.EmptyDataView.description
			)
		}
	}

	func delete(at offsets: IndexSet) {
		guard case .loaded(let messageFilters) = viewModel.state,
			  let offset = offsets.first,
			  !messageFilters.isEmpty else { return }
		let messageFilter = messageFilters[offset]
		viewModel.delete(messageFilter)
	}
}

struct MessageFilterList_Previews: PreviewProvider {
	static var previews: some View {
		MessageFilterList(viewModel: .init())
	}
}
