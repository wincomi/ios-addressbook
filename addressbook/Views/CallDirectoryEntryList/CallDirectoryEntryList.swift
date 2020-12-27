//
//  CallDirectoryEntryList.swift
//  addressbook
//

import SwiftUI
import CallKit

struct CallDirectoryEntryList: View {
	@ObservedObject var viewModel: CallDirectoryEntryListViewModel
	@State private var formType: CallDirectoryEntryForm.FormType?

	private var isEditable: Bool {
		switch viewModel.state {
		case .loaded:
			return true
		default:
			return false
		}
	}

	init(type: CallDirectoryEntry.EntryType) {
		self.viewModel = CallDirectoryEntryListViewModel(type: type)
	}

	var body: some View {
		AsyncContentView(source: viewModel, errorView: errorView) { callDirectoryEntries in
			if !callDirectoryEntries.isEmpty {
				List {
					Section(footer: Text("\(descriptionText(for: viewModel.entryType)) \(L10n.CallDirectoryEntryList.Section.footer)").padding(.horizontal)) {
						ForEach(callDirectoryEntries) { callDirectoryEntry in
							Button {
								formType = .update(callDirectoryEntry)
							} label: {
								CallDirectoryEntryListCell(callDirectoryEntry: callDirectoryEntry)
							}
						}.onDelete(perform: delete(at:))
					}
				}.modifier(CompatibleInsetGroupedListStyle())
			} else {
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
		.navigationBarTitle(viewModel.navigationTitle)
		.navigationBarItems(trailing: addButton.disabled(!isEditable))
		.onAppear(perform: viewModel.load)
		.onReceive(viewModel.didChange, perform: viewModel.load)
		.sheet(item: $formType) { formType in
			NavigationView {
				CallDirectoryEntryForm(formType: formType, entryType: viewModel.entryType)
			}
		}
		.introspectViewController { vc in
			vc.navigationController?.navigationBar.prefersLargeTitles = true
			// Fix prefersLargeTitles not updating until scroll
			vc.navigationController?.navigationBar.sizeToFit()
		}
	}

	@ViewBuilder private func errorView(error: CallDirectoryEntryListError) -> some View {
		switch error {
		case .callDirectoryManagerEnabledStatusDisabled, .callDirectoryManagerEnabledStatusUnknown:
			DisabledStatusView()
		case .error(let error):
			Text(error?.localizedDescription ?? "")
		}
	}

	private var addButton: some View {
		Button {
			formType = .create
		} label: {
			Image(systemName: "plus")
				.font(.system(size: 20))
		}
	}

	private func descriptionText(for entryType: CallDirectoryEntry.EntryType) -> String {
		switch entryType {
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.Section.footer
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.Section.footer
		}
	}

	private func delete(at offsets: IndexSet) {
		guard case .loaded(let callDirectoryEntries) = viewModel.state, let offset = offsets.first else { return }
		let callDirectoryEntry = callDirectoryEntries[offset]
		viewModel.remove(callDirectoryEntry)
	}
}

struct CallDirectoryEntryList_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			CallDirectoryEntryList(type: .identification)
		}
	}
}
