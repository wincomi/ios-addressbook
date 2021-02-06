//
//  CallDirectoryEntryList.DisabledStatusView.swift
//  addressbook
//

import SwiftUI
import CallKit

extension CallDirectoryEntryList {
	struct DisabledStatusView: View {
		var body: some View {
			if #available(iOS 13.4, *) {
				return EmptyDataView(
					title: L10n.CallDirectoryEntryList.DisabledStatusView.title,
					description: L10n.CallDirectoryEntryList.DisabledStatusView.description,
					buttonTitle: L10n.CallDirectoryEntryList.DisabledStatusView.buttonTitle
				) {
					CXCallDirectoryManager.sharedInstance.openSettings { error in
						if let error = error {
							print(error.localizedDescription)
						}
					}
				}
			} else {
				return EmptyDataView(
					title: L10n.CallDirectoryEntryList.DisabledStatusView.title,
					description: L10n.CallDirectoryEntryList.DisabledStatusView.description
				)
			}
		}
	}

	struct DisabledStatusView_Previews: PreviewProvider {
		static var previews: some View {
			DisabledStatusView()
		}
	}
}
