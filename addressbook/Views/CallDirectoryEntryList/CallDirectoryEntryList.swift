//
//  CallDirectoryEntryList.swift
//  addressbook
//

import SwiftUI
import CallKit

struct CallDirectoryEntryList: View {
	@ObservedObject var viewModel: CallDirectoryEntryListViewModel
	@State private var presentedCallDirectoryFormType: CallDirectoryEntryForm.FormType?
	var dismissAction: (() -> Void)?

	init(type: CallDirectoryEntry.EntryType, dismissAction: (() -> Void)? = nil) {
		self.viewModel = CallDirectoryEntryListViewModel(type: type)
		self.dismissAction = dismissAction
	}

	var body: some View {
		Group {
			switch viewModel.callDirectoryManagerEnabledStatus {
			case .enabled:
				if !viewModel.callDirectoryEntries.isEmpty {
					List {
						Section(footer: Text("\(descriptionText(for: viewModel.entryType)) \(L10n.CallDirectoryEntryList.sectionFooter)")) {
							ForEach(viewModel.callDirectoryEntries) { callDirectoryEntry in
								Button {
									presentedCallDirectoryFormType = .edit(callDirectoryEntry)
								} label: {
									CallDirectoryEntryCell(callDirectoryEntry: callDirectoryEntry)
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
							description: "\(L10n.CallDirectoryEntryList.EmptyDataView.description)\n\(descriptionText(for: viewModel.entryType))",
							buttonTitle: L10n.CallDirectoryEntryList.EmptyDataView.buttonTitle
						) {
							presentedCallDirectoryFormType = .add
						}
					}
				}
			case nil:
				EmptyView()
			default:
				CallDirectoryManagerDisabledView()
			}
		}
		.navigationBarTitle(viewModel.navigationTitle)
		.navigationBarItems(leading: dismissButton, trailing: addButton)
		.onAppear(perform: viewModel.refresh)
		.sheet(item: $presentedCallDirectoryFormType) { callDirectoryFormType in
			NavigationView {
				CallDirectoryEntryForm(formType: callDirectoryFormType, entryType: viewModel.entryType)
			}
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

	private var dismissButton: some View {
		Button {
			dismissAction?()
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


