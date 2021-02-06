//
//  SettingsForm.swift
//  addressbook
//

import SwiftUI

struct SettingsForm: View {
	@EnvironmentObject var appSettings: AppSettings
	@ObservedObject var viewModel = SettingsFormViewModel()
	@State private var activeSheet: ActiveSheet?
	@Environment(\.presentationMode) private var presentationMode
	var dismissAction: (() -> Void) = { }

	@available(iOS 14.0, *)
	private var colorPickerSelection: Binding<Color> {
		Binding<Color>(
			get: { Color(appSettings.globalTintColor) },
			set: { appSettings.globalTintColor = UIColor($0) }
		)
	}

	var body: some View {
		Form {
			generalSection
			displaySection
			themeSection
			feedbackSection
		}
		.modifier(CompatibleInsetGroupedListStyle())
		.navigationBarTitle(L10n.SettingsForm.navigationTitle)
		.navigationBarItems(trailing: doneButton)
		.sheet(item: $activeSheet, content: sheet(item:))
	}

	private var doneButton: some View {
		Button(action: dismissAction) {
			Text(L10n.done)
		}
	}
}

private extension SettingsForm {
	// MARK: - General
	var generalSection: some View {
		Section(header: Text(L10n.SettingsForm.GeneralSection.header).padding(.horizontal)) {
			Toggle(isOn: $appSettings.showAllContactsOnAppLaunch) {
				Text(L10n.SettingsForm.GeneralSection.showAllContactsOnAppLaunch)
			}
			Toggle(isOn: $appSettings.preferNicknames) {
				Text(L10n.SettingsForm.GeneralSection.preferNicknames)
			}
			NavigationLink(destination: SortOrderPickerForm(sortOrder: $appSettings.sortOrder)) {
				HStack {
					Text(L10n.AppSettings.SortOrder.title)
						.foregroundColor(Color(UIColor.label))
					Spacer()
					Text(appSettings.sortOrder.localizedTitle)
						.lineLimit(1)
						.minimumScaleFactor(0.5)
						.foregroundColor(Color(UIColor.secondaryLabel))
				}
			}
			NavigationLink(destination: DisplayOrderPickerForm(displayOrder: $appSettings.displayOrder)) {
				HStack {
					Text(L10n.AppSettings.DisplayOrder.title)
						.foregroundColor(Color(UIColor.label))
					Spacer()
					Text(appSettings.displayOrder.localizedTitle)
						.foregroundColor(Color(UIColor.secondaryLabel))
				}
			}
		}
	}

	// MARK: - Display
	var displaySection: some View {
		Section(header: Text(L10n.SettingsForm.DisplaySection.header).padding(.horizontal)) {
			Toggle(isOn: $appSettings.showContactImageInContactList) {
				Text(L10n.SettingsForm.DisplaySection.showContactImage)
			}
			NavigationLink(destination: ContactMenuSettingForm()) {
				Text(L10n.ContactMenuSettingForm.title)
			}
			NavigationLink(destination: ApplicationShortcutItemSettingForm()) {
				Text(L10n.ApplicationShortcutItemsSettingForm.title)
			}
		}
	}

	// MARK: - Theme
	var themeSection: some View {
		Section(header: Text(L10n.SettingsForm.ThemeSection.header).padding(.horizontal)) {
			HStack(spacing: 4) {
				ForEach(AppSettings.globalTintColorDefaultCases, id: \.self) { globalTintColor in
					Button {
						appSettings.globalTintColor = globalTintColor
					} label: {
						CircleColorView(showBorder: .constant(globalTintColor == appSettings.globalTintColor), uiColor: globalTintColor)
					}
				}
				if #available(iOS 14.0, *) {
					ColorPicker(L10n.SettingsForm.ThemeSection.customColor, selection: colorPickerSelection, supportsOpacity: false)
						.labelsHidden()
				}
			}.buttonStyle(PlainButtonStyle())
			NavigationLink(destination: UserInterfaceStylePickerForm(userInterfaceStyle: $appSettings.userInterfaceStyle)) {
				HStack {
					Text(L10n.AppSettings.UserInterfaceStyle.title)
						.foregroundColor(Color(UIColor.label))
					Spacer()
					Text(AppSettings.localizedTitle(for: appSettings.userInterfaceStyle))
						.foregroundColor(Color(UIColor.secondaryLabel))
				}
			}
		}
	}

	// MARK: - Feedback
	private var feedbackSection: some View {
		Section {
			Button {
				UIApplication.shared.open(viewModel.writeReviewURL, options: [:])
			} label: {
				CompatibleLabel {
					Text(L10n.SettingsForm.FeedbackSection.rateThisApp)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: "heart")
						.font(.system(size: 20))
				}
			}
			Button {
				if MailComposeView.canSendMail() {
					activeSheet = .mailComposeView
				} else {
					UIApplication.shared.open(viewModel.feedbackURL, options: [:])
				}
			} label: {
				CompatibleLabel {
					Text(L10n.SettingsForm.FeedbackSection.sendFeedback)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: "paperplane")
						.font(.system(size: 20))
				}
			}
			Button {
				UIApplication.shared.open(viewModel.allAppsURL, options: [:])
			} label: {
				CompatibleLabel {
					Text(L10n.SettingsForm.FeedbackSection.allApps)
						.foregroundColor(Color(UIColor.label))
				} icon: {
					Image(systemName: "app.gift")
						.font(.system(size: 20))
				}
			}
		}
	}
}

extension SettingsForm {
	// MARK: - ActiveSheet
	enum ActiveSheet: Identifiable {
		case mailComposeView

		var id: Int {
			hashValue
		}
	}

	@ViewBuilder private func sheet(item: ActiveSheet) -> some View {
		switch item {
		case .mailComposeView:
			MailComposeView(
				subject: viewModel.feedbackMailSubject,
				toRecipients: [AppSettings.feedbackMailAddress],
				result: .constant(nil)
			)
		}
	}
}

struct SettingsForm_Previews: PreviewProvider {
	static var previews: some View {
		SettingsForm()
	}
}
