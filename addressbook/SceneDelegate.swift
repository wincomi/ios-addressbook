//
//  SceneDelegate.swift
//  addressbook
//

import UIKit
import CallKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var coordinator: RootCoordinator?

	var shortcutItemToProcess: UIApplicationShortcutItem?
	var urlContextToPrecess: UIOpenURLContext?

	// MARK: - UISceneDelegate
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: windowScene)

		let vc = RootSplitViewController()
		coordinator = RootCoordinator(viewController: vc)
		coordinator?.start()
		vc.coordinator = coordinator

		window?.rootViewController = vc
		window?.makeKeyAndVisible()

		window?.tintColor = AppSettings.shared.globalTintColor
		window?.overrideUserInterfaceStyle = AppSettings.shared.userInterfaceStyle

		shortcutItemToProcess = connectionOptions.shortcutItem
		urlContextToPrecess = connectionOptions.urlContexts.first

		reloadCallDirectoryExtension()
	}

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		if let urlContext = URLContexts.first {
			urlContextToPrecess = urlContext
		}
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
		if let applicationShortcutItem = shortcutItemToProcess {
			if let applicationShortcutItem = ApplicationShortcutItem(rawValue: applicationShortcutItem.type) {
				processApplicationShortcutItem(applicationShortcutItem)
			}
			shortcutItemToProcess = nil
		}

		if let urlContext = urlContextToPrecess {
			processURLContext(urlContext)
			urlContextToPrecess = nil
		}
	}

	// MARK: - UIWindowSceneDelegate
	var window: UIWindow?

	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		shortcutItemToProcess = shortcutItem
	}

	// MARK: -
	func reloadCallDirectoryExtension() {
		CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: AppSettings.callDirectoryBundleIdentifier) { error in
			if let error = error {
				print("reloadCallDirectoryExtension: \(error)")
			} else {
				print("reloadCallDirectoryExtension: success")
			}
		}
	}

	private func processApplicationShortcutItem(_ applicationShortcutItem: ApplicationShortcutItem) {
		switch applicationShortcutItem {
		case .contact(let identifier):
			guard let contactListRow = ContactListRow(contactIdentifier: identifier) else {
				coordinator?.presentErrorAlert(message: L10n.unknownContactDescription)
				return
			}
			coordinator?.select(contactListRow)
		case .group(let identifier):
			guard let groupListRow = GroupListRow(groupIdentifier: identifier) else {
				coordinator?.presentErrorAlert(message: L10n.unknownGroupDescription)
				return
			}
			coordinator?.select(groupListRow)
		case .addContact:
			coordinator?.createContact()
		case .searchContacts:
			coordinator?.searchContacts()
		}
	}

	private func processURLContext(_ urlContext: UIOpenURLContext) {
		guard let components = URLComponents(url: urlContext.url, resolvingAgainstBaseURL: true) else { return }
		switch components.host?.lowercased() {
		case "contact":
			guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value,
				  let contactListRow = ContactListRow(contactIdentifier: id) else {
				coordinator?.presentErrorAlert(message: L10n.unknownContactDescription)
				return
			}
			coordinator?.select(contactListRow)
		case "group":
			guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value,
				  let groupListRow = GroupListRow(groupIdentifier: id) else {
				coordinator?.presentErrorAlert(message: L10n.unknownGroupDescription)
				return
			}
			coordinator?.select(groupListRow)
		case "addcontact":
			coordinator?.createContact()
		case "search":
			let q = components.queryItems?.first(where: { $0.name == "q" })?.value
			coordinator?.searchContacts(withSearchText: q)
		case "call":
			guard let phoneNumber = components.queryItems?.first(where: { $0.name == "phoneNumber" })?.value,
				  let url = URL(string: "tel:\(phoneNumber)") else { return }
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:])
			}
		case "sendmessage":
			guard let recipients = components.queryItems?.first(where: { $0.name == "to" })?.value else { return }
			let recipientsArray = recipients.components(separatedBy: ",")
			coordinator?.sendMessage(to: recipientsArray)
		case "sendmail":
			guard let toRecipients = components.queryItems?.first(where: { $0.name == "to" })?.value else { return }
			let toRecipientsArray = toRecipients.components(separatedBy: ",")
			coordinator?.sendMail(toRecipients: toRecipientsArray)
		case "settings":
			coordinator?.presentSettingsForm()
		default:
			print("Cannot process url: \(urlContext.url)")
			break
		}
	}
}
