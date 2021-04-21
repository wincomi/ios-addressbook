//
//  CallDirectoryEntryList.swift
//  addressbook
//

import SwiftUI
import CallKit
import MobileCoreServices

struct CallDirectoryEntryList: View {
	@ObservedObject var viewModel: CallDirectoryEntryListViewModel
	@State private var activeSheetFormType: CallDirectoryEntryForm.FormType?

	init(type: CallDirectoryEntry.EntryType) {
		self.viewModel = CallDirectoryEntryListViewModel(type: type)
	}

	var body: some View {
		AsyncContentView(source: viewModel, errorView: errorView) { callDirectoryEntries in
			if !callDirectoryEntries.isEmpty {
				List {
					Section(footer: Text(descriptionText(for: viewModel.entryType)).padding(.horizontal)) {
						ForEach(callDirectoryEntries, content: rowContent(callDirectoryEntry:))
							.onDelete { offsets in
								/// Temporarily fix an issue that callDirectoryEntry could not be deleted by swiping to delete
								offsets.forEach { offset in
									let callDirectoryEntry = callDirectoryEntries[offset]
									viewModel.remove(callDirectoryEntry)
								}
							}
					}
				}.modifier(CompatibleInsetGroupedListStyle())
			} else {
				emptyView
			}
		}
		.navigationBarTitle(viewModel.navigationTitle)
		.navigationBarItems(trailing: createButton.disabled(!isEditable))
		.onReceive(viewModel.didChange, perform: viewModel.load)
		.sheet(item: $activeSheetFormType) { formType in
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
}

private extension CallDirectoryEntryList {
	var isEditable: Bool {
		switch viewModel.state {
		case .loaded:
			return true
		default:
			return false
		}
	}

	@ViewBuilder func errorView(error: CallDirectoryEntryListError) -> some View {
		switch error {
		case .callDirectoryManagerEnabledStatusDisabled, .callDirectoryManagerEnabledStatusUnknown:
			DisabledStatusView()
		case .error(let error):
			Text(error?.localizedDescription ?? "")
		}
	}

	var emptyView: some View {
		ZStack {
			Color(UIColor.systemGroupedBackground)
				.edgesIgnoringSafeArea(.all)
			EmptyDataView(
				title: L10n.CallDirectoryEntryList.EmptyDataView.title,
				description: descriptionText(for: viewModel.entryType)
			)
		}
	}

	func rowContent(callDirectoryEntry: CallDirectoryEntry) -> some View {
		CallDirectoryEntryListCell(callDirectoryEntry: callDirectoryEntry)
			.contextMenu {
				if let url = callURL(callDirectoryEntry) {
					Button {
						UIApplication.shared.open(url, options: [:])
					} label: {
						Image(systemName: "phone")
						Text(L10n.ContactListRow.ContextMenuItemType.call)
					}
				}
				Button {
					UIPasteboard.general.setValue("\(callDirectoryEntry.phoneNumber)", forPasteboardType: kUTTypePlainText as String)
				} label: {
					Image(systemName: "doc.on.doc")
					Text(L10n.CallDirectoryEntryList.copyPhoneNumber)
				}
				Button {
					viewModel.remove(callDirectoryEntry)
				} label: {
					Image(systemName: "trash")
					Text(L10n.delete)
				}
			}
	}

	func callURL(_ callDirectoryEntry: CallDirectoryEntry) -> URL? {
		if let url = URL(string: "tel:\(callDirectoryEntry.phoneNumber)"),
		   UIApplication.shared.canOpenURL(url) {
			return url
		} else {
			return nil
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

	func descriptionText(for entryType: CallDirectoryEntry.EntryType) -> String {
		switch entryType {
		case .blocking:
			return L10n.CallDirectoryEntryList.BlockingType.Section.footer
		case .identification:
			return L10n.CallDirectoryEntryList.IdentificationType.Section.footer
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
