//
//  CallDirectoryManagerDisabledView.swift
//  addressbook
//

import SwiftUI
import CallKit

struct CallDirectoryManagerDisabledView: View {
	var body: some View {
		if #available(iOS 13.4, *) {
			return EmptyDataView(
				title: L10n.CallDirectoryEntryList.CallDirectoryDisabledView.title,
				description: L10n.CallDirectoryEntryList.CallDirectoryDisabledView.description,
				buttonTitle: L10n.CallDirectoryEntryList.CallDirectoryDisabledView.buttonTitle
			) {
				CXCallDirectoryManager.sharedInstance.openSettings { error in
					if let error = error {
						print(error.localizedDescription)
					}
				}
			}
		} else {
			return EmptyDataView(
				title: L10n.CallDirectoryEntryList.CallDirectoryDisabledView.title,
				description: L10n.CallDirectoryEntryList.CallDirectoryDisabledView.description
			)
		}
	}
}

#if DEBUG
struct CallDirectoryManagerDisabledView_Previews: PreviewProvider {
	static var previews: some View {
		CallDirectoryManagerDisabledView()
	}
}
#endif
