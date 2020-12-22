//
//  CallDirectoryEntryList.swift
//  addressbook
//

import SwiftUI
import CallKit

struct CallDirectoryEntryList: View {
	@ObservedObject var viewModel: CallDirectoryEntryListViewModel
	@State private var formType: CallDirectoryEntryForm.FormType?

	init(type: CallDirectoryEntry.EntryType) {
		self.viewModel = CallDirectoryEntryListViewModel(type: type)
	}

	var body: some View {
		Group {
			switch viewModel.callDirectoryManagerEnabledStatus {
			case .enabled:
				if !viewModel.callDirectoryEntries.isEmpty {
					List {
						Section(footer: Text("\(descriptionText(for: viewModel.entryType)) \(L10n.CallDirectoryEntryList.sectionFooter)").padding(.horizontal)) {
							ForEach(viewModel.callDirectoryEntries) { callDirectoryEntry in
								Button {
									formType = .update(callDirectoryEntry)
								} label: {
									CallDirectoryEntryListCell(callDirectoryEntry: callDirectoryEntry)
								}
							}.onDelete(perform: delete(at:))
						}
					}.modifier(CompatibleInsetGroupedListStyle())
				} else {
					emptyDataView
				}
			case nil:
				EmptyView()
			default:
				DisabledStatusView()
			}
		}
		.navigationBarTitle(viewModel.navigationTitle)
		.navigationBarItems(trailing: addButton)
		.onAppear(perform: viewModel.update)
		.onReceive(viewModel.didChange, perform: viewModel.update)
		.sheet(item: $formType) { formType in
			NavigationView {
				CallDirectoryEntryForm(formType: formType, entryType: viewModel.entryType)
			}
		}
		.introspectViewController { vc in
			vc.navigationController?.navigationBar.prefersLargeTitles = true
		}
	}

	private func descriptionText(for entryType: CallDirectoryEntry.EntryType) -> String {
		switch entryType {
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.sectionFooter
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.sectionFooter
		}
	}

	private var addButton: some View {
		Button {
			formType = .create
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

	private var emptyDataView: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.edgesIgnoringSafeArea(.all)
			EmptyDataView(
				title: L10n.CallDirectoryEntryList.EmptyDataView.title,
				description: descriptionText(for: viewModel.entryType)
			)
		}
	}
}

struct CallDirectoryEntryList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CallDirectoryEntryList(type: .identification)
		}
	}
}
