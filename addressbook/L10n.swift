// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Add
  internal static let add = L10n.tr("Localizable", "add")
  /// All Contacts
  internal static let allContacts = L10n.tr("Localizable", "allContacts")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// Contact
  internal static let contact = L10n.tr("Localizable", "contact")
  /// Contacts
  internal static let contacts = L10n.tr("Localizable", "contacts")
  /// Create New Contact
  internal static let createNewContact = L10n.tr("Localizable", "createNewContact")
  /// Delete
  internal static let delete = L10n.tr("Localizable", "delete")
  /// Done
  internal static let done = L10n.tr("Localizable", "done")
  /// Email addresses
  internal static let emailAddresses = L10n.tr("Localizable", "emailAddresses")
  /// An error occurred.
  internal static let errorAlertTitle = L10n.tr("Localizable", "errorAlertTitle")
  /// Group
  internal static let group = L10n.tr("Localizable", "group")
  /// Groups
  internal static let groups = L10n.tr("Localizable", "groups")
  /// New Contact
  internal static let newContact = L10n.tr("Localizable", "newContact")
  /// OK
  internal static let ok = L10n.tr("Localizable", "OK")
  /// Phone numbers
  internal static let phoneNumbers = L10n.tr("Localizable", "phoneNumbers")
  /// Search Contacts
  internal static let searchContacts = L10n.tr("Localizable", "searchContacts")
  /// Share
  internal static let share = L10n.tr("Localizable", "share")
  /// Unknown contact
  internal static let unknownContact = L10n.tr("Localizable", "unknownContact")
  /// This contact cannot be retrieved.
  internal static let unknownContactDescription = L10n.tr("Localizable", "unknownContactDescription")
  /// Unknown group
  internal static let unknownGroup = L10n.tr("Localizable", "unknownGroup")
  /// This contact cannot be retrieved.
  internal static let unknownGroupDescription = L10n.tr("Localizable", "unknownGroupDescription")

  internal enum AppSettings {
    internal enum DisplayOrder {
      /// System Default
      internal static let `default` = L10n.tr("Localizable", "AppSettings.displayOrder.default")
      /// Last, First
      internal static let familyNameFirst = L10n.tr("Localizable", "AppSettings.displayOrder.familyNameFirst")
      /// First, Last
      internal static let givenNameFirst = L10n.tr("Localizable", "AppSettings.displayOrder.givenNameFirst")
      /// Display Order
      internal static let title = L10n.tr("Localizable", "AppSettings.displayOrder.title")
    }
    internal enum SortOrder {
      /// According to Display Order
      internal static let `default` = L10n.tr("Localizable", "AppSettings.sortOrder.default")
      /// Last name
      internal static let familyName = L10n.tr("Localizable", "AppSettings.sortOrder.familyName")
      /// First Name
      internal static let givenName = L10n.tr("Localizable", "AppSettings.sortOrder.givenName")
      /// Sort Order
      internal static let title = L10n.tr("Localizable", "AppSettings.sortOrder.title")
    }
    internal enum UserInterfaceStyle {
      /// Always On
      internal static let dark = L10n.tr("Localizable", "AppSettings.userInterfaceStyle.dark")
      /// Always Off
      internal static let light = L10n.tr("Localizable", "AppSettings.userInterfaceStyle.light")
      /// Dark Mode
      internal static let title = L10n.tr("Localizable", "AppSettings.userInterfaceStyle.title")
      /// Depends on System
      internal static let unspecified = L10n.tr("Localizable", "AppSettings.userInterfaceStyle.unspecified")
    }
  }

  internal enum ApplicationShortcutItemsSettingForm {
    /// Quick Actions
    internal static let navigationTitle = L10n.tr("Localizable", "ApplicationShortcutItemsSettingForm.navigationTitle")
    /// Home Screen Quick Actions
    internal static let title = L10n.tr("Localizable", "ApplicationShortcutItemsSettingForm.title")
    internal enum AddingSection {
      /// You can add contacts and groups from the list of contacts and groups.
      internal static let footerText = L10n.tr("Localizable", "ApplicationShortcutItemsSettingForm.AddingSection.footerText")
    }
    internal enum Section {
      /// Up to four are displayed from the top.
      internal static let footerText = L10n.tr("Localizable", "ApplicationShortcutItemsSettingForm.Section.footerText")
    }
  }

  internal enum CallDirectoryEntryForm {
    /// Name
    internal static let name = L10n.tr("Localizable", "CallDirectoryEntryForm.name")
    /// Phone Number
    internal static let phoneNumber = L10n.tr("Localizable", "CallDirectoryEntryForm.phoneNumber")
    internal enum AddType {
      /// Add Phone Number
      internal static let navigationBarTitle = L10n.tr("Localizable", "CallDirectoryEntryForm.AddType.navigationBarTitle")
    }
    internal enum EditType {
      /// Edit Phone Number
      internal static let navigationBarTitle = L10n.tr("Localizable", "CallDirectoryEntryForm.EditType.navigationBarTitle")
    }
    internal enum NameSection {
      /// Enter the name that will be displayed when you receive a call.
      internal static let footer = L10n.tr("Localizable", "CallDirectoryEntryForm.NameSection.footer")
    }
    internal enum PhoneNumberSection {
      /// Enter only numbers with country code.
      internal static let footer = L10n.tr("Localizable", "CallDirectoryEntryForm.PhoneNumberSection.footer")
    }
  }

  internal enum CallDirectoryEntryList {
    internal enum BlockingType {
      /// Call Blocking
      internal static let navigationTitle = L10n.tr("Localizable", "CallDirectoryEntryList.BlockingType.navigationTitle")
      /// You will not receive phone calls from phone numbers on the block list.
      internal static let sectionFooter = L10n.tr("Localizable", "CallDirectoryEntryList.BlockingType.sectionFooter")
    }
    internal enum CallDirectoryDisabledView {
      /// Enable
      internal static let buttonTitle = L10n.tr("Localizable", "CallDirectoryEntryList.CallDirectoryDisabledView.buttonTitle")
      /// Available after enabling in Settings.
      internal static let description = L10n.tr("Localizable", "CallDirectoryEntryList.CallDirectoryDisabledView.description")
      /// Call Blocking & Identification
      internal static let title = L10n.tr("Localizable", "CallDirectoryEntryList.CallDirectoryDisabledView.title")
    }
    internal enum EmptyDataView {
      /// Touch add button at the top to add a phone number.
      internal static let description = L10n.tr("Localizable", "CallDirectoryEntryList.EmptyDataView.description")
      /// The list is empty.
      internal static let title = L10n.tr("Localizable", "CallDirectoryEntryList.EmptyDataView.title")
    }
    internal enum IdentificationType {
      /// Caller ID
      internal static let navigationTitle = L10n.tr("Localizable", "CallDirectoryEntryList.IdentificationType.navigationTitle")
      /// The name on the list will be displayed when you receive phone calls.
      internal static let sectionFooter = L10n.tr("Localizable", "CallDirectoryEntryList.IdentificationType.sectionFooter")
    }
  }

  internal enum ContactList {
    internal enum ConfirmDeleteAlert {
      /// Plural format key: "Are you sure you want to delete %#@contacts@?"
      internal static func title(_ p1: Int) -> String {
        return L10n.tr("Localizable", "ContactList.ConfirmDeleteAlert.Title", p1)
      }
    }
    internal enum NavigationItems {
      /// Deselect All
      internal static let deselectAll = L10n.tr("Localizable", "ContactList.NavigationItems.deselectAll")
      /// Select All
      internal static let selectAll = L10n.tr("Localizable", "ContactList.NavigationItems.selectAll")
    }
  }

  internal enum ContactListFooterView {
    /// Plural format key: "%#@contacts@"
    internal static func text(_ p1: Int) -> String {
      return L10n.tr("Localizable", "ContactListFooterView.Text", p1)
    }
  }

  internal enum ContactListRow {
    /// No name
    internal static let noName = L10n.tr("Localizable", "ContactListRow.noName")
    internal enum ContextMenuItemType {
      /// Add to Quick Actions
      internal static let addToApplicationShortcutItems = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.addToApplicationShortcutItems")
      /// Add to group
      internal static let addToGroup = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.addToGroup")
      /// Call
      internal static let call = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.call")
      /// Remove from Quick Actions
      internal static let removeFromApplicationShortcutItems = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.removeFromApplicationShortcutItems")
      /// Remove from group
      internal static let removeFromGroup = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.removeFromGroup")
      /// Mail
      internal static let sendMail = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.sendMail")
      /// Message
      internal static let sendMessage = L10n.tr("Localizable", "ContactListRow.ContextMenuItemType.sendMessage")
    }
  }

  internal enum ContactMenuSettingForm {
    /// Contact Menu
    internal static let navigationTitle = L10n.tr("Localizable", "ContactMenuSettingForm.navigationTitle")
    /// Custom Contact Menu
    internal static let title = L10n.tr("Localizable", "ContactMenuSettingForm.title")
    internal enum OptionsSection {
      /// Always display all phone numbers and email address at first.
      internal static let footerText = L10n.tr("Localizable", "ContactMenuSettingForm.OptionsSection.footerText")
      /// Display all menus at first
      internal static let isContactContextMenuDisplayInline = L10n.tr("Localizable", "ContactMenuSettingForm.OptionsSection.isContactContextMenuDisplayInline")
    }
    internal enum Section {
      /// Touch and hold a contact to show selected contact menus.
      internal static let footerText = L10n.tr("Localizable", "ContactMenuSettingForm.Section.footerText")
    }
  }

  internal enum ContactStoreError {
    /// Access to your contacts has been denied.
    internal static let accessDeniedDescription = L10n.tr("Localizable", "ContactStoreError.accessDeniedDescription")
    /// We need contact permission to import contacts.
    internal static let accessNotDeterminedDescription = L10n.tr("Localizable", "ContactStoreError.accessNotDeterminedDescription")
    /// Access to your contacts has been restricted.
    internal static let accessRestrictedDescriptoin = L10n.tr("Localizable", "ContactStoreError.accessRestrictedDescriptoin")
    /// An error occured while retrieving contacts.
    internal static let cannotFetchErrorDescription = L10n.tr("Localizable", "ContactStoreError.cannotFetchErrorDescription")
    /// Request permission
    internal static let requestPermission = L10n.tr("Localizable", "ContactStoreError.requestPermission")
    /// An unknown error occured.
    internal static let unknownErrorDescription = L10n.tr("Localizable", "ContactStoreError.unknownErrorDescription")
  }

  internal enum ContactsItemSource {
    /// Plural format key: "%#@contacts@"
    internal static func title(_ p1: Int) -> String {
      return L10n.tr("Localizable", "ContactsItemSource.Title", p1)
    }
  }

  internal enum EditContactsForm {
    /// Delete Profile Image
    internal static let deleteProfileImage = L10n.tr("Localizable", "EditContactsForm.deleteProfileImage")
    /// Department
    internal static let departmentName = L10n.tr("Localizable", "EditContactsForm.departmentName")
    /// Job Title
    internal static let jobTitle = L10n.tr("Localizable", "EditContactsForm.jobTitle")
    /// Edit Contacts
    internal static let navigationTitle = L10n.tr("Localizable", "EditContactsForm.navigationTitle")
    /// Company
    internal static let organizationName = L10n.tr("Localizable", "EditContactsForm.organizationName")
    /// Profile Image
    internal static let profileImage = L10n.tr("Localizable", "EditContactsForm.profileImage")
    /// Leave blank if you don't want multiple edit.
    internal static let sectionFooter = L10n.tr("Localizable", "EditContactsForm.sectionFooter")
    /// Select Image
    internal static let selectImage = L10n.tr("Localizable", "EditContactsForm.selectImage")
  }

  internal enum EditGroupsForm {
    /// Edit Groups
    internal static let navigationTitle = L10n.tr("Localizable", "EditGroupsForm.navigationTitle")
    internal enum ContactSection {
      /// This contact will be displayed in selected groups below.
      internal static let footer = L10n.tr("Localizable", "EditGroupsForm.ContactSection.footer")
    }
  }

  internal enum GroupList {
    internal enum ConfirmDeleteAlert {
      /// Are you sure you want to delete '%@' group?\nContacts will not be deleted.
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Localizable", "GroupList.ConfirmDeleteAlert.message", String(describing: p1))
      }
      /// Delete '%@'
      internal static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "GroupList.ConfirmDeleteAlert.title", String(describing: p1))
      }
    }
    internal enum CreateGroupAlert {
      /// Enter a name for new group.
      internal static let message = L10n.tr("Localizable", "GroupList.CreateGroupAlert.message")
      /// Save
      internal static let save = L10n.tr("Localizable", "GroupList.CreateGroupAlert.save")
      /// New Group
      internal static let title = L10n.tr("Localizable", "GroupList.CreateGroupAlert.title")
      internal enum TextField {
        /// Name
        internal static let placeholder = L10n.tr("Localizable", "GroupList.CreateGroupAlert.TextField.placeholder")
      }
    }
    internal enum EmptyDataView {
      /// Unable to access your contacts.
      internal static let title = L10n.tr("Localizable", "GroupList.EmptyDataView.title")
    }
    internal enum NavigationItems {
      /// Edit Groups
      internal static let editButton = L10n.tr("Localizable", "GroupList.NavigationItems.editButton")
    }
    internal enum UpdateGroupAlert {
      /// Rename Group
      internal static let title = L10n.tr("Localizable", "GroupList.UpdateGroupAlert.title")
    }
  }

  internal enum GroupListRow {
    internal enum ContextMenuItemType {
      /// Rename
      internal static let rename = L10n.tr("Localizable", "GroupListRow.ContextMenuItemType.rename")
    }
  }

  internal enum SearchList {
    internal enum Section {
      internal enum EmailAddresses {
        /// Email Address
        internal static let header = L10n.tr("Localizable", "SearchList.Section.EmailAddresses.header")
      }
      internal enum Name {
        /// Name
        internal static let header = L10n.tr("Localizable", "SearchList.Section.Name.header")
      }
      internal enum PhoneNumbers {
        /// Phone Number
        internal static let header = L10n.tr("Localizable", "SearchList.Section.PhoneNumbers.header")
      }
    }
  }

  internal enum SettingsForm {
    /// Settings
    internal static let navigationTitle = L10n.tr("Localizable", "SettingsForm.navigationTitle")
    /// Nothing to restore.
    internal static let nothingToRestore = L10n.tr("Localizable", "SettingsForm.nothingToRestore")
    /// Only for Contacts⁺ Pro
    internal static let onlyForContactsPlusPro = L10n.tr("Localizable", "SettingsForm.onlyForContactsPlusPro")
    /// Restore Purchase
    internal static let restorePurchase = L10n.tr("Localizable", "SettingsForm.restorePurchase")
    /// Your purchases have been restored.
    internal static let successRestorePurchases = L10n.tr("Localizable", "SettingsForm.successRestorePurchases")
    /// Thank you!
    internal static let thankYou = L10n.tr("Localizable", "SettingsForm.thankYou")
    /// Thank you for your purchase.
    internal static let thankYouForYourPurchase = L10n.tr("Localizable", "SettingsForm.thankYouForYourPurchase")
    /// Thank you for your support :)
    internal static let thankYouForYourSupport = L10n.tr("Localizable", "SettingsForm.thankYouForYourSupport")
    internal enum DisplaySection {
      /// Display
      internal static let header = L10n.tr("Localizable", "SettingsForm.DisplaySection.header")
      /// Show contact image
      internal static let showContactImage = L10n.tr("Localizable", "SettingsForm.DisplaySection.showContactImage")
    }
    internal enum DonationSection {
      /// Donation
      internal static let header = L10n.tr("Localizable", "SettingsForm.DonationSection.header")
    }
    internal enum FeedbackSection {
      /// All apps from the developer
      internal static let allApps = L10n.tr("Localizable", "SettingsForm.FeedbackSection.allApps")
      /// Feedback
      internal static let header = L10n.tr("Localizable", "SettingsForm.FeedbackSection.header")
      /// Rate this app
      internal static let rateThisApp = L10n.tr("Localizable", "SettingsForm.FeedbackSection.rateThisApp")
      /// Send Feedback
      internal static let sendFeedback = L10n.tr("Localizable", "SettingsForm.FeedbackSection.sendFeedback")
    }
    internal enum GeneralSection {
      /// Display Order
      internal static let displayOrder = L10n.tr("Localizable", "SettingsForm.GeneralSection.displayOrder")
      /// General
      internal static let header = L10n.tr("Localizable", "SettingsForm.GeneralSection.header")
      /// Prefer nicknames
      internal static let preferNicknames = L10n.tr("Localizable", "SettingsForm.GeneralSection.preferNicknames")
      /// Show contacts on app launch
      internal static let showAllContactsOnAppLaunch = L10n.tr("Localizable", "SettingsForm.GeneralSection.showAllContactsOnAppLaunch")
    }
    internal enum ProSection {
      /// Contacts⁺ Pro
      internal static let contactsPlusPro = L10n.tr("Localizable", "SettingsForm.ProSection.contactsPlusPro")
      /// Purchase
      internal static let purchase = L10n.tr("Localizable", "SettingsForm.ProSection.purchase")
    }
    internal enum UnlockedProSection {
      /// Thank you for purchasing Contacts⁺ Pro.
      internal static let message = L10n.tr("Localizable", "SettingsForm.UnlockedProSection.message")
    }
    internal enum ThemeSection {
      /// Custom Color
      internal static let customColor = L10n.tr("Localizable", "SettingsForm.themeSection.customColor")
      /// Theme
      internal static let header = L10n.tr("Localizable", "SettingsForm.themeSection.header")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
