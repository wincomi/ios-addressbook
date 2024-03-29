//
//  MessageFilterList.swift
//  addressbook
//

import SwiftUI

struct MessageFilterList: View {
	@ObservedObject var viewModel: MessageFilterListViewModel
	@State private var activeSheetFormType: MessageFilterForm.FormType?
	let didChange = StorageController.didChange

	var body: some View {
		AsyncContentView(source: viewModel, content: contentView(messageFilters:))
			.navigationBarTitle(L10n.MessageFilterList.navigationTitle)
			.navigationBarItems(trailing: createButton)
			.onReceive(didChange, perform: viewModel.load)
			.sheet(item: $activeSheetFormType) { formType in
				NavigationView {
					MessageFilterForm(formType: formType)
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
				Section(footer: Text(L10n.MessageFilterList.footer)) {
					ForEach(messageFilters) { messageFilter in
						rowContent(messageFilter: messageFilter)
					}.onDelete(perform: delete(at:))
				}
			}.modifier(CompatibleInsetGroupedListStyle())
		}
	}

	func rowContent(messageFilter: MessageFilter) -> some View {
		Button {
			activeSheetFormType = .update(messageFilter)
		} label: {
			HStack {
				CompatibleLabel {
					Text(messageFilter.filterText)
						.foregroundColor(Color(.label))
				} icon: {
					Image(systemName: messageFilter.action.systemImageName)
				}

				Spacer()

				switch messageFilter.type {
				case .any:
					EmptyView()
				default:
					Image(systemName: messageFilter.type.systemImageName)
				}

				if case .junk = messageFilter.action {
					Image(systemName: "bell.slash.fill")
						.foregroundColor(Color(.systemRed))
				}
			}
		}
	}

	var createButton: some View {
		Button {
			activeSheetFormType = .create
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
