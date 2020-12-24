//
//  SettingsFormViewModel.swift
//  addressbook
//

import Foundation

final class SettingsFormViewModel: ObservableObject {
	let writeReviewURL = URL(string: "https://itunes.apple.com/app/id\(AppSettings.appStoreId)?action=write-review")!

	var feedbackMailSubject: String {
		var subject = "\(AppSettings.displayName) v\(AppSettings.shortVersionString)"
		if AppSettings.isRunningBeta {
			subject += " (\(AppSettings.buildVersion))"
		}
		return subject
	}

	var feedbackURL: URL {
		URL(string: "mailto:\(AppSettings.feedbackMailAddress)?subject=\(feedbackMailSubject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!
	}

	let allAppsURL = URL(string: "https://apps.apple.com/developer/id\(AppSettings.developerId)")!
}
