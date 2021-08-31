//
//  SidebarList.ErrorView.swift
//  addressbook
//

import SwiftUI

extension SidebarList {
	struct ErrorView: View {
		var error: Error
		var requestPermissionAction: (() -> Void)

		var body: some View {
			switch error as? ContactStoreError {
			case .accessNotDetermined:
				Section(footer: Text(L10n.ContactStoreError.accessNotDeterminedDescription)) {
					Button {
						ContactStore.requestAuthorization { _ in
							requestPermissionAction()
						}
					} label: {
						HStack {
							Spacer()
							Text(L10n.ContactStoreError.requestPermission)
							Spacer()
						}
					}
				}
			case .accessRestricted:
				Section(footer: Text(L10n.ContactStoreError.accessRestrictedDescriptoin)) {
					Button {
						guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
						if UIApplication.shared.canOpenURL(url) {
							UIApplication.shared.open(url, options: [:])
						}
					} label: {
						HStack {
							Spacer()
							Text(L10n.ContactStoreError.requestPermission)
							Spacer()
						}
					}
				}
			default:
				Section(footer: Text(L10n.ContactStoreError.accessDeniedDescription)) {
					Button {
						guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
						if UIApplication.shared.canOpenURL(url) {
							UIApplication.shared.open(url, options: [:])
						}
					} label: {
						HStack {
							Spacer()
							Text(L10n.ContactStoreError.requestPermission)
							Spacer()
						}
					}
				}
			}
		}
	}
}
