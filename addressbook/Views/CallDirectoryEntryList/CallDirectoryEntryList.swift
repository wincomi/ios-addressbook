//
//  CallDirectoryEntryList.swift
//  addressbook
//

import SwiftUI
import CallKit

typealias CallDirectoryEntryListViewController = UIHostingController<CallDirectoryEntryList>

struct CallDirectoryEntryList: View {
	@ObservedObject var viewModel: CallDirectoryEntryListViewModel
	@State private var presentedCallDirectoryFormType: CallDirectoryEntryForm.FormType?
	var dismissAction: (() -> Void) = { }

	init(type: CallDirectoryEntry.EntryType) {
		self.viewModel = CallDirectoryEntryListViewModel(type: type)
	}

	var body: some View {
		NavigationView {
			view(for: viewModel.callDirectoryManagerEnabledStatus)
			.navigationBarTitle(viewModel.navigationBarTitle)
			.navigationBarItems(leading: dismissButton, trailing: addButton)
			.onAppear(perform: viewModel.refresh)
			.sheet(item: $presentedCallDirectoryFormType) { callDirectoryFormType in
				NavigationView {
					CallDirectoryEntryForm(formType: callDirectoryFormType, entryType: viewModel.entryType)
				}
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	@ViewBuilder private func view(for callDirectoryManagerEnabledStatus: CXCallDirectoryManager.EnabledStatus?) -> some View {
		switch callDirectoryManagerEnabledStatus {
		case .enabled:
			if viewModel.callDirectoryEntries.isEmpty {
				EmptyDataView(
					title: L10n.CallDirectoryEntryList.EmptyDataView.title,
					description: L10n.CallDirectoryEntryList.EmptyDataView.description
				)
			} else {
				List {
					ForEach(viewModel.callDirectoryEntries) { callDirectoryEntry in
						Button {
							presentedCallDirectoryFormType = .edit(callDirectoryEntry)
						} label: {
							CallDirectoryEntryCell(callDirectoryEntry: callDirectoryEntry)
						}
					}.onDelete(perform: delete(at:))
				}.listStyle(GroupedListStyle())
			}
		case nil:
			EmptyView()
		default:
			CallDirectoryManagerDisabledView()
		}
	}

	private var dismissButton: some View {
		Button {
			dismissAction()
		} label: {
			Image(systemName: "xmark")
				.font(.system(size: 20))
  		}
	}

	private var addButton: some View {
		Button {
			presentedCallDirectoryFormType = .add
		} label: {
			Image(systemName: "plus")
				.font(.system(size: 20))
		}
		.disabled(viewModel.callDirectoryManagerEnabledStatus != .enabled)
	}

	private func delete(at offsets: IndexSet) {
		offsets.forEach { offset in
			let callDirectoryEntry = viewModel.callDirectoryEntries[offset]
			viewModel.remove(callDirectoryEntry)
		}
	}
}

#if DEBUG
struct CallDirectoryEntryList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CallDirectoryEntryList(type: .identification)
		}
	}
}
#endif

