//
//  SidebarList.swift
//  addressbook
//

import SwiftUI
import Contacts

struct SidebarList: View {
	weak var coordinator: RootCoordinator?
	@ObservedObject var viewModel = SidebarListViewModel()
	@Environment(\.editMode) private var editMode
	@State private var activeSheet: ActiveSheet?
	@State private var activeAlert: ActiveAlert?
	@State private var activeActionSheet: ActiveActionSheet?

	private var isEditable: Bool {
		switch viewModel.state {
		case .loaded:
			return true
		default:
			return false
		}
	}

	var body: some View {
		List {
			AsyncContentView(source: viewModel, errorView: errorView) { sections in
				ForEach(sections) { section in
					Section(header: section.headerText.map { Text($0).padding(.horizontal) }) {
						ForEach(section.rows) { groupListRow in
							SidebarListCell(groupListRow: groupListRow) {
								coordinator?.select(groupListRow)
							}.contextMenu {
								contextMenuItems(for: groupListRow)
							}.onDragCompatible {
								viewModel.itemProvider(for: groupListRow) ?? NSItemProvider()
							}.deleteDisabled(!isDeletable(groupListRow))
							.disabled(editMode?.wrappedValue == .active && !isDeletable(groupListRow))
						}.onDelete { offsets in
							guard let groupListRow = offsets.first.map({ section.rows[$0] }),
								  case .group(let group) = groupListRow.type else { return }
							activeActionSheet = .confirmDelete(group)
						}
					}
				}
			}

			// MARK: - Utilities Section
			Section(header: Text(L10n.SidebarList.utilities).padding(.horizontal)) {
				NavigationButton {
					coordinator?.presentCallDirectoryEntryList(type: .identification)
				} label: {
					CompatibleLabel {
						Text(L10n.CallDirectoryEntryList.IdentificationType.navigationTitle)
							.foregroundColor(Color(UIColor.label))
					} icon: {
						Image(systemName: "questionmark.circle")
							.font(.system(size: 20))
					}
				}
				NavigationButton {
					coordinator?.presentCallDirectoryEntryList(type: .blocking)
				} label: {
					CompatibleLabel {
						Text(L10n.CallDirectoryEntryList.BlockingType.navigationTitle)
							.foregroundColor(Color(UIColor.label))
					} icon: {
						Image(systemName: "bell.slash")
					}
				}
				NavigationButton {
					coordinator?.presentMessageFilterList()
				} label: {
					CompatibleLabel {
						Text(L10n.MessageFilterList.navigationTitle)
							.foregroundColor(Color(UIColor.label))
					} icon: {
						Image(systemName: "xmark.bin")
					}
				}
			}.disabled(editMode?.wrappedValue == .active)

			// MARK: - Settings Section
			Section {
				Button {
					coordinator?.presentSettingsForm()
				} label: {
					CompatibleLabel {
						Text(L10n.SettingsForm.navigationTitle)
							.foregroundColor(Color(UIColor.label))
					} icon: {
						Image(systemName: "gear")
							.font(.system(size: 20))
					}
				}
			}.disabled(editMode?.wrappedValue == .active)
		}
		.onAppear(perform: viewModel.load)
		.onReceive(ContactStore.didChange) {
			withAnimation {
				viewModel.load()
			}
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.groups)
		.navigationBarItems(
			leading: EditButton().disabled(!isEditable),
			trailing: createButton.disabled(!isEditable)
		)
		.sheet(item: $activeSheet, content: sheet(item:))
		.alert(item: $activeAlert, content: alert(item:))
		.actionSheet(item: $activeActionSheet, content: actionSheet(item:))
		.introspectViewController { vc in
			vc.navigationController?.navigationBar.prefersLargeTitles = true
			// Fix prefersLargeTitles not updating until scroll
			vc.navigationController?.navigationBar.sizeToFit()
		}
	}

	// MARK: -

	private func isDeletable(_ groupListRow: GroupListRow) -> Bool {
		switch groupListRow.type {
		case .allContacts:
			return false
		case .group:
			return true
		}
	}

	@ViewBuilder private func errorView(error: Error) -> some View {
		ErrorView(error: error) {
			DispatchQueue.main.async {
				viewModel.load()
			}
		}
	}

	@ViewBuilder private var createButton: some View {
		if #available(iOS 14.0, *) {
			Menu {
				Button {
					activeSheet = .newGroup
				} label: {
					Label(L10n.CreateGroupForm.navigationTitle, systemImage: "folder.badge.plus")
				}
				Button {
					coordinator?.createContact()
				} label: {
					Label(L10n.newContact, systemImage: "person.crop.circle.badge.plus")
				}
			} label: {
				Label(L10n.add, systemImage: "plus")
					.labelStyle(IconOnlyLabelStyle())
					.font(.system(size: 21))
			}
		} else {
			Button {
				activeActionSheet = .createButton
			} label: {
				Image(systemName: "plus")
					.font(.system(size: 21))
			}
		}
	}

	@ViewBuilder func contextMenuItems(for groupListRow: GroupListRow) -> some View {
		ContextMenuButtons.SendMessageButton(for: groupListRow) { recipients in
			coordinator?.sendMessage(to: recipients)
		}
		ContextMenuButtons.SendMailButton(for: groupListRow) { toRecipients in
			coordinator?.sendMail(toRecipients: toRecipients)
		}
		ContextMenuButtons.ApplicationShortcutItemSettingButton(for: groupListRow) { applicationShortcutItem, isEnabledInAppSettings in
			if isEnabledInAppSettings {
				viewModel.removeApplicationShortcutItemFromAppSettings(applicationShortcutItem)
			} else {
				viewModel.addApplicationShortcutItemToAppSettings(applicationShortcutItem)
			}
		}
		ContextMenuButtons.ShareButton(activityItems: viewModel.activityItems(for: groupListRow) ?? []) { activityItems in
			coordinator?.presentActivityViewController(activityItems: activityItems)
		}
		ContextMenuButtons.RenameButton(for: groupListRow) { group in
			activeSheet = .updateGroup(group)
		}
		ContextMenuButtons.DeleteButton(for: groupListRow) { group in
			activeActionSheet = .confirmDelete(group)
		}
	}
}

extension SidebarList {
	// MARK: - ActiveSheet
	enum ActiveSheet: Hashable, Identifiable {
		case newGroup
		case updateGroup(CNGroup)

		var id: Int {
			hashValue
		}
	}

	@ViewBuilder private func sheet(item: ActiveSheet) -> some View {
		switch item {
		case .newGroup:
			NavigationView {
				CreateGroupForm(coordinator: coordinator)
			}.navigationViewStyle(StackNavigationViewStyle())
		case .updateGroup(let group):
			NavigationView {
				UpdateGroupForm(coordinator: coordinator, viewModel: UpdateGroupFormViewModel(currentGroup: group))
			}.navigationViewStyle(StackNavigationViewStyle())
		}
	}

	// MARK: - ActiveAlert
	enum ActiveAlert: Hashable, Identifiable {
		case alertItem(AlertItem)

		var id: Int {
			hashValue
		}
	}

	private func alert(item: ActiveAlert) -> Alert {
		switch item {
		case .alertItem(let alertItem):
			return Alert(
				title: Text(alertItem.title),
				message: alertItem.message.map { Text($0) },
				dismissButton: .cancel(Text(L10n.ok))
			)
		}
	}

	// MARK: - ActiveActionSheet
	enum ActiveActionSheet: Hashable, Identifiable {
		case confirmDelete(CNGroup)
		case createButton

		var id: Int {
			hashValue
		}
	}

	private func actionSheet(item: ActiveActionSheet) -> ActionSheet {
		switch item {
		case .confirmDelete(let group):
			return ActionSheet(
				title: Text(L10n.SidebarList.ActiveActionSheet.ConfirmDelete.title(group.name)),
				message: Text(L10n.SidebarList.ActiveActionSheet.ConfirmDelete.message(group.name)),
				buttons: [
					.destructive(Text(L10n.delete), action: {
						do {
							try viewModel.delete(group)
						} catch {
							activeAlert = .alertItem(AlertItem(error: error))
						}
					}),
					.cancel(Text(L10n.ok))
				]
			)
		case .createButton:
			return ActionSheet(
				title: Text(L10n.CreateGroupForm.navigationTitle),
				buttons: [
					.default(Text(L10n.CreateGroupForm.navigationTitle), action: {
						activeSheet = .newGroup
					}),
					.default(Text(L10n.newContact), action: {
						coordinator?.createContact()
					}),
					.cancel()
				]
			)
		}
	}
}

struct SidebarList_Previews: PreviewProvider {
	static var previews: some View {
		SidebarList()
	}
}
