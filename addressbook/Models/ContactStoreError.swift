//
//  ContactStoreError.swift
//  addressbook
//

import Foundation

enum ContactStoreError: Error, LocalizedError {
	case accessNotDetermined
	case accessRestricted
	case accessDenied
	case cannotFetch
	case unknown

	var localizedDescription: String {
		switch self {
		case .accessNotDetermined:
			return L10n.ContactStoreError.accessNotDeterminedDescription
		case .accessRestricted:
			return L10n.ContactStoreError.accessRestrictedDescriptoin
		case .accessDenied:
			return L10n.ContactStoreError.accessDeniedDescription
		case .cannotFetch:
			return L10n.ContactStoreError.cannotFetchErrorDescription
		case .unknown:
			return L10n.ContactStoreError.unknownErrorDescription
		}
	}
}
