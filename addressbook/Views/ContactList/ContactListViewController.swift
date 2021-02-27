//
//  ContactListViewController.swift
//  addressbook
//

import UIKit
import Combine
import Contacts

final class ContactListViewController: UITableViewController, ListDataSourceRenderable {
	let viewModel: ContactListViewModel
	weak var coordinator: RootCoordinator?

	var isEditingTableViewRow = false
	var configurePopoverPresentationController: ((UIPopoverPresentationController) -> Void)?
	var becomeFirstResponderSearchBarOnAppear = false {
		didSet {
			if becomeFirstResponderSearchBarOnAppear {
				searchController.searchBar.becomeFirstResponder()
			}
		}
	}

	private var cancellables = Set<AnyCancellable>()

	// MARK: - ListDataSourceRenderable
	typealias Section = ContactListSection
	typealias Failure = ContactStoreError

	lazy var dataSource: DataSource = {
		let dataSource = DataSource(tableView: tableView) { tableView, indexPath, contactListRow in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListCell.reuseIdentifier, for: indexPath) as? ContactListCell else { return nil }
			cell.configure(with: contactListRow)
			return cell
		}

		dataSource.canEdit = { _, _ in
			return true
		}

		dataSource.commit = { tableView, editingStyle, indexPath in
			guard let contactListRow = dataSource.itemIdentifier(for: indexPath) else { return }

			if editingStyle == .delete {
				self.configurePopoverPresentationController = {
					$0.sourceView = tableView
					$0.sourceRect = tableView.rectForRow(at: indexPath)
				}
				self.presentConfirmDeleteAlert(contactListRows: [contactListRow])
			}
		}

		dataSource.sectionIndexTitles = { _ in
			let showSectionIndexTitles = dataSource.snapshot().itemIdentifiers.count >= 20
			return showSectionIndexTitles ? dataSource.snapshot().sectionIdentifiers.compactMap(\.headerText) : nil
		}

		dataSource.titleForHeader = { _, section in
			let showSectionTitles = dataSource.snapshot().sectionIdentifiers.count >= 5
			return showSectionTitles ? dataSource.snapshot().sectionIdentifiers[section].headerText : nil
		}

		return dataSource
	}()

	// MARK: - Search Controller
	lazy var searchController: UISearchController = {
		let searchListViewModel = SearchListViewModel(groupListRow: viewModel.groupListRow)
		let searchListViewController = SearchListViewController(viewModel: searchListViewModel)
		searchListViewController.coordinator = self.coordinator

		let searchController = UISearchController(searchResultsController: searchListViewController)
		searchController.searchResultsUpdater = searchListViewController
		searchController.searchBar.delegate = searchListViewController
		searchController.searchBar.scopeButtonTitles = SearchListScope.scopeButtonTitles(from: viewModel.groupListRow)

		return searchController
	}()

	// MARK: - Navigation Items
	lazy var createContactButton = UIBarButtonItem(title: L10n.newContact, image: UIImage(systemName: "plus"), handler: {
		self.coordinator?.createContact()
	})

	lazy var selectAllButton = UIBarButtonItem(title: L10n.ContactList.NavigationItems.selectAll, handler: {
		self.isSelectedAllRowsInTableView ? self.deselectAllRowsInTableView() : self.selectAllRowsInTableView()
	})

	// MARK: - Toolbar Items
	lazy var toolbarItemsProvider: ContactListToolbarItemsProvider = {
		let provider = ContactListToolbarItemsProvider()

		provider.actionHandler = { actionButton in
			self.configurePopoverPresentationController = {
				$0.barButtonItem = actionButton
			}

			do {
				try self.viewModel.share(self.selectedRowsInTableView)
			} catch {
				self.coordinator?.presentErrorAlert(message: error.localizedDescription)
			}
		}

		provider.sendMessageHandler = { _ in
			let recipients = self.selectedRowsInTableView
				.map(\.contact.phoneNumbers)
				.reduce([]) { (initialResult, phoneNumbers) -> [String] in
					initialResult + phoneNumbers.map(\.value.stringValue)
				}
			self.coordinator?.sendMessage(to: recipients)
		}

		provider.sendMailHandler = { _ in
			let recipients = self.selectedRowsInTableView
				.map(\.contact.emailAddresses)
				.reduce([]) { (initialResult, emailAddresses) -> [String] in
					initialResult + emailAddresses.map { $0.value as String }
				}
			self.coordinator?.sendMail(toRecipients: recipients)
		}

		provider.addToGroupHandler = { _ in
			self.coordinator?.addToGroup(contacts: self.selectedRowsInTableView.map(\.contact))
		}

		provider.editHandler = { _ in
			self.coordinator?.edit(contacts: self.selectedRowsInTableView.map(\.contact))
		}

		provider.deleteHandler = { deleteButton in
			self.configurePopoverPresentationController = {
				$0.sourceView = self.view
				$0.barButtonItem = deleteButton
			}
			self.presentConfirmDeleteAlert(contactListRows: self.selectedRowsInTableView)
		}

		return provider
	}()

	// MARK: - Initialization
	init(groupListRow: GroupListRow) {
		self.viewModel = ContactListViewModel(groupListRow: groupListRow)

		super.init(style: .plain)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()

		setupUI()
		bindViewModel()

		viewModel.viewDidLoad()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if becomeFirstResponderSearchBarOnAppear {
			DispatchQueue.main.async {
				self.searchController.searchBar.becomeFirstResponder()
			}
		}
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		if isEditingTableViewRow { return }

		updateUI()
	}

	// MARK: - Setting up
	private func setupUI() {
		title = viewModel.navigationTitle
		toolbarItems = toolbarItemsProvider.toolbarItems(withFlexibleSpace: true)

		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.rightBarButtonItems = [createContactButton, editButtonItem]
		navigationItem.largeTitleDisplayMode = .never

		setupTableView()

		updateUI()
	}

	private func setupTableView() {
		tableView.register(ContactListCell.self, forCellReuseIdentifier: ContactListCell.reuseIdentifier)

		tableView.delegate = self
		tableView.dataSource = dataSource

		tableView.dragDelegate = self

		tableView.allowsMultipleSelectionDuringEditing = true
	}

	private func updateUI(animated: Bool = true) {
		let isDataSourceEmpty = dataSource.snapshot().numberOfItems == 0
		editButtonItem.isEnabled = !isDataSourceEmpty
		createContactButton.isEnabled = !isEditing
		selectAllButton.title = isSelectedAllRowsInTableView ? L10n.ContactList.NavigationItems.deselectAll : L10n.ContactList.NavigationItems.selectAll

		toolbarItemsProvider.toolbarItems().forEach {
			$0.isEnabled = isSelectedAnyRowInTableView
		}

		navigationController?.setToolbarHidden(!isEditing, animated: animated)
		navigationItem.setHidesBackButton(isEditing, animated: animated)
		navigationItem.leftBarButtonItem = isEditing ? selectAllButton : nil
		navigationItem.searchController?.searchBar.isUserInteractionEnabled = !isEditing

		if case .loaded(let sections) = viewModel.listState {
			if sections.isEmpty {
				tableView.tableFooterView = UIView()
				let emptyDataView = EmptyDataView(title: L10n.ContactListFooterView.text(0), description: nil)
				install(emptyDataView: emptyDataView)
			} else {
				let tableFooterView = footerView(numberOfContacts: dataSource.snapshot().numberOfItems)
				tableFooterView.sizeToFit()
				tableFooterView.clipsToBounds = true
				tableView.tableFooterView = tableFooterView
				tableView.separatorStyle = .singleLine
			}
		} else {
			tableView.tableFooterView = UIView()
			removeEmptyDataView()
		}
	}

	private func bindViewModel() {
		viewModel.$listState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.render(state)
			}.store(in: &cancellables)

		viewModel.$activityItems
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: present(activityItems:))
			.store(in: &cancellables)
	}

	// MARK: - Presenting View Controller
	private func present(activityItems: [Any]) {
		let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		vc.excludedActivityTypes = [.assignToContact]

		if let popoverPresentationController = vc.popoverPresentationController {
			configurePopoverPresentationController?(popoverPresentationController)
		}

		present(vc, animated: true) {
			self.configurePopoverPresentationController = nil
			self.viewModel.activityItems = nil
		}
	}

	private func presentConfirmDeleteAlert(contactListRows: [ContactListRow]) {
		let alert = UIAlertController(title: L10n.ContactList.ConfirmDeleteAlert.title(contactListRows.count), message: nil, preferredStyle: .actionSheet)
		if let popoverPresentationController = alert.popoverPresentationController {
			configurePopoverPresentationController?(popoverPresentationController)
		}

		alert.addAction(.cancelAction())

		if case .group(let group) = viewModel.groupListRow.type {
			let removeFromGroup = UIAlertAction(title: L10n.ContactListRow.ContextMenuItemType.removeFromGroup, style: .destructive) { _ in
				do {
					try self.viewModel.remove(contactListRows, from: group)
				} catch {
					self.coordinator?.presentErrorAlert(message: error.localizedDescription)
				}
			}
			alert.addAction(removeFromGroup)
		}

		let deleteAction = UIAlertAction(title: L10n.delete, style: .destructive) { _ in
			do {
				try self.viewModel.delete(contactListRows)
			} catch {
				self.coordinator?.presentErrorAlert(message: error.localizedDescription)
			}
		}
		alert.addAction(deleteAction)

		present(alert, animated: true) {
			self.configurePopoverPresentationController = nil
		}
	}
}

// MARK: - ListStateRenderable
extension ContactListViewController: ListStateRenderable {
	func render(_ state: State, animated: Bool = false) {
		switch state {
		case .loading:
			break
		case .error(let error):
			let view = EmptyDataView(title: L10n.errorAlertTitle, description: error.localizedDescription)
			install(emptyDataView: view)
		case .loaded(let sections):
			removeEmptyDataView()
			render(sections, animated: animated)
		}
		updateUI(animated: animated)
	}
}

// MARK: - EmptyDataViewPresentable
extension ContactListViewController: EmptyDataViewPresentable {

}

// MARK: - UITableViewDelegate
extension ContactListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.isEditing {
			updateUI()
			return
		}

		guard let contactListRow = dataSource.itemIdentifier(for: indexPath) else { return }

		coordinator?.select(contactListRow)
	}

	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if tableView.isEditing {
			updateUI()
			return
		}
	}

	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		isEditingTableViewRow = true
	}

	override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		isEditingTableViewRow = false
	}

	override func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
		self.setEditing(true, animated: true)
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let contactListRow = dataSource.itemIdentifier(for: indexPath) else { return nil }

		let provider: ContactListRowContextMenuConfigurationProvider = {
			switch viewModel.groupListRow.type {
			case .allContacts:
				return ContactListRowContextMenuConfigurationProvider(contactListRow: contactListRow)
			case .group(let group):
				let provider = ContactListRowContextMenuConfigurationProvider(contactListRow: contactListRow, currentGroup: group)
				provider.removeFromGroupHandler = { contactListRow in
					do {
						try self.viewModel.remove([contactListRow], from: group)
					} catch {
						self.coordinator?.presentErrorAlert(message: error.localizedDescription)
					}
				}
				return provider
			}
		}()

		provider.callHandler = { (_, phoneNumberStringValue) in
			self.coordinator?.call(phoneNumberStringValue)
		}

		provider.sendMessageHandler = { (_, phoneNumberStringValue) in
			self.coordinator?.sendMessage(to: [phoneNumberStringValue])
		}

		provider.sendMailHandler = { (_, emailAddress) in
			self.coordinator?.sendMail(toRecipients: [emailAddress])
		}

		provider.editGroupsHandler = { contactListRow in
			self.coordinator?.editGroups(of: contactListRow.contact)
		}

		provider.shareHandler = { contactListRow in
			self.configurePopoverPresentationController = {
				$0.sourceView = tableView
				$0.sourceRect = tableView.rectForRow(at: indexPath)
			}

			do {
				try self.viewModel.share([contactListRow])
			} catch {
				self.coordinator?.presentErrorAlert(message: error.localizedDescription)
			}
		}

		provider.applicationShortcutItemSettingHandler = { (contactListRow, applicationShortcutItem, isApplicationShortcutItemEnabled) in
			if isApplicationShortcutItemEnabled {
				AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
			} else {
				AppSettings.shared.applicationShortcutItems.append(applicationShortcutItem)
			}
		}

		provider.deleteHandler = { contactListRow in
			do {
				try self.viewModel.delete([contactListRow])
			} catch {
				self.coordinator?.presentErrorAlert(message: error.localizedDescription)
			}
		}

		return provider.contextMenuConfiguration(for: AppSettings.shared.enabledContactContextMenuItemsTypes)
	}
}

// MARK: - UITableViewDragDelegate
extension ContactListViewController: UITableViewDragDelegate {
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let contactListRow = dataSource.itemIdentifier(for: indexPath),
			  let dragItems = viewModel.dragItems(contact: contactListRow.contact) else {
			return []
		}

		return dragItems
	}
}
