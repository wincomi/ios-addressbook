//
//  SiderbarList+RequestPermissionSection.swift
//  addressbook
//

import SwiftUI

extension SidebarList {
	struct RequestPermissionSection<AuthorizedView: View>: View {
		let notDeterminedAction: (() -> Void)
		let authorizedView: (() -> AuthorizedView)

		var body: some View {
			switch ContactStore.authorizationStatus {
			case .authorized:
				authorizedView()
			case .notDetermined:
				Section(footer: Text(L10n.ContactStoreError.accessNotDeterminedDescription).padding(.horizontal)) {
					Button {
						ContactStore.requestAuthorization { _ in
							notDeterminedAction()
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
				Section(footer: Text(L10n.ContactStoreError.accessDeniedDescription).padding(.horizontal)) {
					openSettingsButton
				}
			}
		}

		private var openSettingsButton: some View {
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
