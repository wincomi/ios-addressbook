//
//  SearchListViewController.swift
//  addressbook
//

import UIKit
import Combine
import Contacts

final class SearchListViewController: UITableViewController, ListDataSourceRenderable {
	weak var coordinator: RootCoordinator?
	let viewModel: SearchListViewModel

	var configurePopoverPresentationController: ((UIPopoverPresentationController) -> Void)?

	private var cancellables = Set<AnyCancellable>()

	// MARK: - ListDataSourceRenderable
	typealias Section = SearchListSection

	lazy var dataSource: DataSource = {
		DataSource(tableView: tableView) { tableView, indexPath, searchListRow in
			guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchListCell.reuseIdentifier, for: indexPath) as? SearchListCell else { fatalError() }
			cell.configure(with: searchListRow)
			return cell
		}
	}()

	// MARK: - Initialization
	init(viewModel: SearchListViewModel) {
		self.viewModel = viewModel
		super.init(style: .grouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController
	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
		bindViewModel()
	}

	// MARK: - Setting up
	private func setupTableView() {
		tableView.register(SearchListCell.self, forCellReuseIdentifier: SearchListCell.reuseIdentifier)

		tableView.dataSource = dataSource
		tableView.delegate = self
	}

	private func bindViewModel() {
		viewModel.$sections.sink { [weak self] sections in
			self?.dataSource.apply(with: sections, animatingDifferences: false)
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
}

// MARK: - UITableViewDelegate
extension SearchListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let searchListRow = dataSource.itemIdentifier(for: indexPath) else { return }

		coordinator?.select(searchListRow.contactListRow)
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let searchListRow = dataSource.itemIdentifier(for: indexPath) else { return nil }

		let provider: ContactListRowContextMenuConfigurationProvider = {
			switch viewModel.groupListRow.type {
			case .allContacts:
				return ContactListRowContextMenuConfigurationProvider(contactListRow: searchListRow.contactListRow)
			case .group(let group):
				let provider = ContactListRowContextMenuConfigurationProvider(contactListRow: searchListRow.contactListRow, currentGroup: group)
				provider.removeFromGroupHandler = { searchListRow in
					self.viewModel.remove([searchListRow], from: group)
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

		provider.editGroupsHandler = { searchListRow in
			self.coordinator?.editGroups(of: searchListRow.contact)
		}

		provider.shareHandler = { searchListRow in
			self.configurePopoverPresentationController = {
				$0.sourceView = tableView
				$0.sourceRect = tableView.rectForRow(at: indexPath)
			}
			self.viewModel.share([searchListRow])
		}

		provider.applicationShortcutItemSettingHandler = { (searchListRow, applicationShortcutItem, isApplicationShortcutItemEnabled) in
			if isApplicationShortcutItemEnabled {
				AppSettings.shared.applicationShortcutItems.removeAll { $0 == applicationShortcutItem }
			} else {
				AppSettings.shared.applicationShortcutItems.append(applicationShortcutItem)
			}
		}

		provider.deleteHandler = { searchListRow in
			self.viewModel.delete([searchListRow])
		}

		return provider.contextMenuConfiguration(for: AppSettings.shared.enabledContactContextMenuItemsTypes)
	}
}

// MARK: - UISearchResultsUpdating
extension SearchListViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		viewModel.searchText = searchController.searchBar.text ?? ""
	}
}

// MARK: - UISearchBarDelegate
extension SearchListViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchListScope(groupListRow: viewModel.groupListRow, selectedScope: selectedScope) else { return }
		viewModel.searchScope = searchScope
	}
}
