//
//  AppSettings.swift
//

import Combine
import UIKit

final class AppSettings: ObservableObject {
	typealias UserInterfaceStyle = UIUserInterfaceStyle

	static let shared = AppSettings()

	static let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
	static let callDirectoryBundleIdentifier = "com.wincomi.ios.addressbook.CallDirectory"
	static let supportedLocalizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }

	static var isCallKitSupported: Bool {
		guard let regionCode = NSLocale.current.regionCode else { return false }

		if regionCode.contains("CN") || regionCode.contains("CHN") {
			return false
		} else {
			return true
		}
	}

	static var displayName: String {
		Bundle.main.localizedInfoDictionary!["CFBundleDisplayName"] as! String
	}

	static var shortVersionString: String {
		Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
	}

	static var buildVersion: String {
		Bundle.main.infoDictionary!["CFBundleVersion"] as! String
	}

	static let isRunningBeta: Bool = {
		#if DEBUG
		return true
		#else
		return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
		#endif
	}()

	static let feedbackMailAddress = "admin@wincomi.com"
	static let developerId = "849003301"
	static let appStoreId = "1412803405"

	static var globalTintColorDefaultCases: [UIColor] = [.systemBlue, .systemGreen, .systemIndigo, .systemOrange, .systemPurple, .systemRed, .systemTeal, .systemYellow]
	static let userInterfaceStyleAllCases: [UserInterfaceStyle] = [.unspecified, .dark, .light]

	static func localizedTitle(for userInterfaceStyle: UserInterfaceStyle) -> String {
		switch userInterfaceStyle {
		case .unspecified:
			return L10n.AppSettings.UserInterfaceStyle.unspecified
		case .dark:
			return L10n.AppSettings.UserInterfaceStyle.dark
		case .light:
			return L10n.AppSettings.UserInterfaceStyle.light
		@unknown default:
			return ""
		}
	}

	private init() { }

	// MARK: - General
	@UserDefault("showAllContactsOnAppLaunch", store: .appGroup)
	var showAllContactsOnAppLaunch = false {
		willSet { objectWillChange.send() }
	}

	@UserDefault("preferNicknames", store: .appGroup)
	var preferNicknames = false {
		willSet { objectWillChange.send() }
	}

	enum SortOrder: Int, CaseIterable {
		case `default` = 1
		case givenName = 2
		case familyName = 3

		var localizedTitle: String {
			switch self {
			case .default:
				return L10n.AppSettings.SortOrder.default
			case .givenName:
				return L10n.AppSettings.SortOrder.givenName
			case .familyName:
				return L10n.AppSettings.SortOrder.familyName
			}
		}
	}

	@UserDefault("sortOrder", store: .appGroup)
	var sortOrder = SortOrder.default {
		willSet { objectWillChange.send() }
	}

	enum DisplayOrder: Int, CaseIterable {
		case `default` = 0
		case givenNameFirst = 1
		case familyNameFirst = 2

		var localizedTitle: String {
			switch self {
			case .default:
				return L10n.AppSettings.DisplayOrder.default
			case .givenNameFirst:
				return L10n.AppSettings.DisplayOrder.givenNameFirst
			case .familyNameFirst:
				return L10n.AppSettings.DisplayOrder.familyNameFirst
			}
		}
	}

	@UserDefault("displayOrder", store: .appGroup)
	var displayOrder = DisplayOrder.default {
		willSet { objectWillChange.send() }
	}

	// MARK: - Display
	@UserDefault("showContactImageInContactList", store: .appGroup)
	var showContactImageInContactList = true {
		willSet { objectWillChange.send() }
	}

	@UserDefault("hideLocalContainer", store: .appGroup)
	var hideLocalContainer = false {
		willSet { objectWillChange.send() }
	}

	@UserDefault("applicationShortcutItems", store: .appGroup)
	var applicationShortcutItems = [ApplicationShortcutItem]() {
		willSet { objectWillChange.send() }
		didSet {
			UIApplication.shared.shortcutItems = applicationShortcutItems.map { UIApplicationShortcutItem($0) }
		}
	}

	@UserDefault("enabledContactContextMenuItemsTypes", store: .appGroup)
	var enabledContactContextMenuItemsTypes = ContactListRow.ContextMenuItemType.allCases {
		willSet { objectWillChange.send() }
	}

	@UserDefault("isContactContextMenuDisplayInline", store: .appGroup)
	var isContactContextMenuDisplayInline = false {
		willSet { objectWillChange.send() }
	}

	// MARK: - Theme
	@UserDefault("globalTintColor", store: .appGroup)
	var globalTintColor = UIColor.systemBlue {
		willSet { objectWillChange.send() }
		didSet {
			let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
			sceneDelegate?.window?.tintColor = globalTintColor
		}
	}

	@UserDefault("userInterfaceStyle", store: .appGroup)
	var userInterfaceStyle = UserInterfaceStyle.unspecified {
		willSet { objectWillChange.send() }
		didSet {
			let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
			sceneDelegate?.window?.overrideUserInterfaceStyle = userInterfaceStyle
		}
	}
}
