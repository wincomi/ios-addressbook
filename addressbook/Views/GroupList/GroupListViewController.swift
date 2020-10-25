//
//  GroupListViewController.swift
//  addressbook
//

import UIKit
import Combine
import Contacts

final class GroupListViewController: UITableViewController, ListDataSourceRenderable {
	let viewModel = GroupListViewModel()
	weak var coordinator: RootCoordinator?
	
	var configurePopoverPresentationController: ((UIPopoverPresentationController) -> Void)?
	private var cancellables = Set<AnyCancellable>()
	
	// MARK: - ListDataSourceRenderable
	typealias Section = GroupListSection
	typealias Failure = ContactStoreError
	
	lazy var dataSource: DataSource = {
		let dataSource = DataSource(tableView: tableView) { tableView, indexPath, groupListRow in
			let cellProvider = DataSource.CellProviders.default()
			let cell = cellProvider(tableView, indexPath, groupListRow)
			cell?.accessoryType = .disclosureIndicator
			return cell
		}
		
		dataSource.titleForHeader = { _, section in
			let isContainersCountOne = dataSource.snapshot().sectionIdentifiers.count <= 2
			return !isContainersCountOne ? dataSource.snapshot().sectionIdentifiers[section].headerText : nil
		}
		
		dataSource.canEdit = { _, indexPath in
			guard let groupListRow = dataSource.itemIdentifier(for: indexPath) else { return false }
			
			switch groupListRow.type {
			case .allContacts:
				return false
			case .group:
				return true
			}
		}
		
		dataSource.commit = { tableView, editingStyle, indexPath in
			guard let groupListRow = dataSource.itemIdentifier(for: indexPath) else { return }
			
			if editingStyle == .delete {
				self.configurePopoverPresentationController = {
					$0.sourceView = tableView
					$0.sourceRect = tableView.rectForRow(at: indexPath)
				}
				self.presentConfirmDeleteAlert(groupListRow)
			}
		}
		
		return dataSource
	}()
	
	// MARK: - Navigation Items
	lazy var createButton: UIBarButtonItem = {
		UIBarButtonItem(title: L10n.add, image: UIImage(systemName: "plus"), contextMenuItems: createButtonContextMenuItems, contextMenuItemsHandler: { contextMenuItems in
			self.present(contextMenuItems: contextMenuItems, animated: true) {
				$0.barButtonItem = self.createButton
			}
		})
	}()
	
	var createButtonContextMenuItems: [ContextMenuItem] {
		[
			ContextMenuItem(title: L10n.GroupList.CreateGroupAlert.title, image: UIImage(systemName: "folder.badge.plus"), children: createGroupContextMenuItems) {
				// if children.isEmpty
				guard let defaultContainer = self.viewModel.allContainers.first else { return }
				self.presentCreateGroupAlert(newGroupAt: defaultContainer)
			},
			ContextMenuItem(title: L10n.newContact, image: UIImage(systemName: "person.crop.circle.badge.plus")) {
				self.coordinator?.createContact()
			}
		]
	}
	
	var createGroupContextMenuItems: [ContextMenuItem] {
		let containers = self.viewModel.allContainers
		guard containers.count > 1 else { return [] }

		let contextMenuItems = containers.map { container in
			ContextMenuItem(title: container.displayName, image: UIImage(systemName: "tray")) {
				self.presentCreateGroupAlert(newGroupAt: container)
			}
		}
		return contextMenuItems
	}
	
	lazy var moreButton: UIBarButtonItem = {
		UIBarButtonItem(
			title: L10n.SettingsForm.navigationTitle,
			image: UIImage(systemName: "ellipsis.circle"),
			contextMenuItems: [
				ContextMenuItem(title: L10n.GroupList.NavigationItems.editButton, image: UIImage(systemName: "checkmark.circle")) {
					self.setEditing(true, animated: true)
				},
				ContextMenuItem(title: L10n.SettingsForm.navigationTitle, image: UIImage(systemName: "gear")) {
					self.coordinator?.presentSettingsForm()
				}
			],
			contextMenuItemsHandler: { contextMenuItems in
				self.present(contextMenuItems: contextMenuItems, animated: true) {
					$0.barButtonItem = self.moreButton
				}
			}
		)
	}()
	
	// MARK: - Initialization
	init() {
		super.init(style: .insetGrouped)
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

		// Fix initial frame of EmptyDataView in iPad
		render(viewModel.listState, animated: animated)
	}

	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		updateUI(animated: animated)
	}
	
	// MARK: - Setting up
	private func setupUI() {
		title = L10n.groups
		
		navigationController?.navigationBar.prefersLargeTitles = true
		
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.rightBarButtonItems = [createButton, moreButton]
		
		setupTableView()

		updateUI()
	}
	
	private func setupTableView() {
		tableView.register(ValueTableViewCell.self, forCellReuseIdentifier: ValueTableViewCell.reuseIdentifier)
		
		tableView.delegate = self
		tableView.dataSource = dataSource
		
		tableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
		tableView.dragDelegate = self
		tableView.dropDelegate = self
	}
	
	private func bindViewModel() {
		viewModel.$listState
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.render(state)
			}.store(in: &cancellables)
		
		viewModel.$alertItem
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { alertItem in
				self.present(alertItem) { self.viewModel.alertItem = nil }
			}
			.store(in: &cancellables)
		
		viewModel.$activityItems
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: present(activityItems:))
			.store(in: &cancellables)
	}
	
	private func updateUI(animated: Bool = true) {
		if isEditing {
			navigationItem.rightBarButtonItems = [editButtonItem]
		} else {
			navigationItem.rightBarButtonItems = [createButton, moreButton]
		}

		switch viewModel.listState {
		case .loaded:
			navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
		default:
			navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
		}
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
	
	/// 새로운 그룹 추가 Alert
	private func presentCreateGroupAlert(newGroupAt container: CNContainer) {
		let alert = UIAlertController(title: L10n.GroupList.CreateGroupAlert.title, message: L10n.GroupList.CreateGroupAlert.message, preferredStyle: .alert)
		alert.addAction(.cancelAction())
		
		alert.addTextField { textField in
			textField.placeholder = L10n.GroupList.CreateGroupAlert.TextField.placeholder
		}
		
		let saveAction = UIAlertAction(title: L10n.GroupList.CreateGroupAlert.save, style: .default) { action in
			guard let textFieldText = alert.textFields?.first?.text else { return }
			self.viewModel.createGroup(groupName: textFieldText, to: container)
		}
		saveAction.isEnabled = false
		alert.addAction(saveAction)
		
		NotificationCenter.default
			.publisher(for: UITextField.textDidChangeNotification)
			.map { ($0.object as? UITextField)?.text?.isEmpty ?? true }
			.sink { isTextFieldTextEmpty in
				saveAction.isEnabled = !isTextFieldTextEmpty
			}.store(in: &cancellables)
		
		self.present(alert, animated: true)
	}
	
	/// 그룹 편집 Alert
	private func presentUpdateGroupAlert(for group: CNGroup) {
		let alert = UIAlertController(title: L10n.GroupList.UpdateGroupAlert.title, message: nil, preferredStyle: .alert)
		alert.addAction(.cancelAction())
		
		alert.addTextField { textField in
			textField.placeholder = L10n.GroupList.CreateGroupAlert.TextField.placeholder
			textField.text = group.name
		}
		
		let saveAction = UIAlertAction(title: L10n.GroupList.CreateGroupAlert.save, style: .default) { action in
			guard let textFieldText = alert.textFields?.first?.text else { return }
			self.viewModel.update(group, groupName: textFieldText)
		}
		saveAction.isEnabled = false
		alert.addAction(saveAction)
		
		NotificationCenter.default
			.publisher(for: UITextField.textDidChangeNotification)
			.map { ($0.object as? UITextField)?.text?.isEmpty ?? true }
			.sink { isTextFieldTextEmpty in
				saveAction.isEnabled = !isTextFieldTextEmpty
			}.store(in: &cancellables)
		
		self.present(alert, animated: true)
	}
	
	/// 그룹 삭제 Alert (밀어서 삭제 할 때)
	private func presentConfirmDeleteAlert(_ groupListRow: GroupListRow) {
		guard case .group(let group) = groupListRow.type else { return }
		
		let title = L10n.GroupList.ConfirmDeleteAlert.title(groupListRow.text)
		let message = L10n.GroupList.ConfirmDeleteAlert.message(groupListRow.text)

		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		alert.addAction(.cancelAction())
		
		let deleteAction = UIAlertAction(title: L10n.delete, style: .destructive) { _ in
			self.viewModel.delete(group)
		}
		alert.addAction(deleteAction)

		if let popoverPresentationController = alert.popoverPresentationController {
			configurePopoverPresentationController?(popoverPresentationController)
		}

		present(alert, animated: true) {
			self.configurePopoverPresentationController = nil
		}
	}
}

// MARK: - ListStateRenderable
extension GroupListViewController: ListStateRenderable {
	func render(_ state: State, animated: Bool = false) {
		switch state {
		case .loading:
			break
		case .error(let error):
			let view = emptyDataView(for: error)
			install(emptyDataView: view)
		case .loaded(let sections):
			removeEmptyDataView()
			render(sections, animated: animated)
		}
		self.updateUI(animated: animated)
	}
}

// MARK: - EmptyDataViewPresentable
extension GroupListViewController: EmptyDataViewPresentable {
	private func emptyDataView(for error: Failure) -> EmptyDataView {
		switch error {
		case .accessNotDetermined:
			return EmptyDataView(title: L10n.GroupList.EmptyDataView.title, description: error.localizedDescription, buttonTitle: L10n.ContactStoreError.requestPermission) { [weak self] in
				ContactStore.requestAuthorization { status in
					self?.viewModel.refresh()
				}
			}
		default:
			return EmptyDataView(title: L10n.errorAlertTitle, description: error.localizedDescription, buttonTitle: L10n.ContactStoreError.requestPermission) {
				guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
				if UIApplication.shared.canOpenURL(url) {
					UIApplication.shared.open(url, options: [:])
				}
			}
		}
	}
}

// MARK: - UITableViewDelegate
extension GroupListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let groupListRow = dataSource.itemIdentifier(for: indexPath) else { return }
		
		coordinator?.select(groupListRow)
	}
	
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let groupListRow = dataSource.itemIdentifier(for: indexPath) else { return nil }
		
		let provider = GroupListRowContextMenuConfigurationProvider(groupListRow: groupListRow)

		provider.sendMessageHandler = { (groupListRow, phoneNumberStringValues) in
			self.coordinator?.sendMessage(to: phoneNumberStringValues)
		}

		provider.sendMailHandler = { (groupListRow, emailAddressValues) in
			self.coordinator?.sendMail(toRecipients: emailAddressValues)
		}

		provider.shareHandler = { groupListRow in
			self.configurePopoverPresentationController = {
				$0.sourceView = tableView
				$0.sourceRect = tableView.rectForRow(at: indexPath)
			}
			self.viewModel.share(groupListRow)
		}
		
		provider.renameHandler = { group in
			self.presentUpdateGroupAlert(for: group)
		}
		
		provider.applicationShortcutItemSettingHandler = { (group, applicationShortcutItem, isApplicationShortcutItemEnabled) in
			if isApplicationShortcutItemEnabled {
				AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
			} else {
				AppSettings.shared.applicationShortcutItems.append(applicationShortcutItem)
			}
		}
		
		provider.deleteHandler = { group in
			self.viewModel.delete(group)
		}

		return provider.contextMenuConfiguration()
	}
}

// MARK: - UITableViewDragDelegate
extension GroupListViewController: UITableViewDragDelegate {
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let groupListRow = dataSource.itemIdentifier(for: indexPath),
			  let dragItems = groupListRow.dragItems() else { return [] }
		
		return dragItems
	}
}

// MARK: - UITableViewDropDelegate
extension GroupListViewController: UITableViewDropDelegate {
	func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
		guard let indexPath = coordinator.destinationIndexPath,
			  let groupListRow = dataSource.itemIdentifier(for: indexPath),
			  case .group(let group) = groupListRow.type else { return }
		
		coordinator.session.loadObjects(ofClass: CNContact.self) { items in
			guard let contacts = items as? [CNContact] else { return }
			self.viewModel.add(contacts, to: group)
		}
	}
	
	func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
		return session.canLoadObjects(ofClass: CNContact.self)
	}
	
	func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
		tableView.indexPathsForVisibleRows?.forEach { indexPath in
			tableView.cellForRow(at: indexPath)?.setHighlighted(false, animated: true)
		}
		
		guard let indexPath = destinationIndexPath, let groupListRow = dataSource.itemIdentifier(for: indexPath) else {
			return UITableViewDropProposal(operation: .cancel)
		}
		
		guard case .group = groupListRow.type else {
			return UITableViewDropProposal(operation: .forbidden)
		}
		
		tableView.cellForRow(at: indexPath)?.setHighlighted(true, animated: true)
		
		return UITableViewDropProposal(operation: .copy)
	}

	func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession) {
		tableView.indexPathsForVisibleRows?.forEach { indexPath in
			tableView.cellForRow(at: indexPath)?.setHighlighted(false, animated: true)
		}
	}
}
