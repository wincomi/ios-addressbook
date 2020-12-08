//
//  SettingsForm.swift
//  addressbook
//

import SwiftUI

typealias SettingsFormViewController = UIHostingController<SettingsForm>

struct SettingsForm: View {
	@ObservedObject var appSettings = AppSettings.shared
	@ObservedObject var viewModel = SettingsFormViewModel()
	@State private var isPresentedMailComposeView: Bool = false
	var dismissAction: (() -> Void) = { }

	@available(iOS 14.0, *)
	private var colorPickerSelection: Binding<Color> {
		Binding<Color>(
			get: { Color(appSettings.globalTintColor) },
			set: { appSettings.globalTintColor = UIColor($0) }
		)
	}

	private var feedbackMailSubject: String {
		var subject = "\(AppSettings.displayName) v\(AppSettings.shortVersionString)"
		if AppSettings.isRunningBeta {
			subject += " (\(AppSettings.buildVersion))"
		}
		return subject
	}

	var body: some View {
		NavigationView {
			Form {
				generalSection
				displaySection
				themeSection
					.disabled(!appSettings.isUnlockedPro)
				feedbackSection
			}
			.modifier(CompatibleInsetGroupedListStyle())
			.navigationBarTitle(L10n.SettingsForm.navigationTitle)
			.navigationBarItems(trailing: doneButton)
			.onAppear(perform: viewModel.onAppear)
			.sheet(isPresented: $isPresentedMailComposeView) {
				MailComposeView(subject: feedbackMailSubject, toRecipients: [AppSettings.feedbackMailAddress], result: .constant(nil))
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}

	private var doneButton: some View {
		Button(action: dismissAction) {
			Text(L10n.done).bold()
		}
	}

	// MARK: - Sections
	private var generalSection: some View {
		Section(header: Text(L10n.SettingsForm.GeneralSection.header)) {
			Toggle(isOn: $appSettings.showAllContactsOnAppLaunch) {
				Text(L10n.SettingsForm.GeneralSection.showAllContactsOnAppLaunch)
			}
			Toggle(isOn: $appSettings.preferNicknames) {
				Text(L10n.SettingsForm.GeneralSection.preferNicknames)
			}
			NavigationLink(destination: sortOrderPickerForm) {
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
			NavigationLink(destination: displayOrderPickerForm) {
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

	private var sortOrderPickerForm: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.SortOrder.title), items: AppSettings.SortOrder.allCases, selection: $appSettings.sortOrder) { row, isSelected in
			HStack {
				Text(row.localizedTitle)
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}

	private var displayOrderPickerForm: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.DisplayOrder.title), items: AppSettings.DisplayOrder.allCases, selection: $appSettings.displayOrder) { row, isSelected in
			HStack {
				Text(row.localizedTitle)
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}

	private var displaySection: some View {
		Section(header: Text(L10n.SettingsForm.DisplaySection.header)) {
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

	private var themeSection: some View {
		Section(
			header: Text(L10n.SettingsForm.ThemeSection.header),
			footer: appSettings.isUnlockedPro ? AnyView(EmptyView()) : AnyView(Text(L10n.SettingsForm.onlyForContactsPlusPro))
		) {
			HStack(spacing: 4) {
				ForEach(AppSettings.globalTintColorDefaultCases, id: \.self) { globalTintColor in
					Button {
						appSettings.globalTintColor = globalTintColor
					} label: {
						circleColorView(for: globalTintColor)
					}
				}
				if #available(iOS 14.0, *) {
					ColorPicker(L10n.SettingsForm.ThemeSection.customColor, selection: colorPickerSelection, supportsOpacity: false)
						.labelsHidden()
				}
			}.buttonStyle(PlainButtonStyle())
			NavigationLink(destination: userInterfaceStylePickerForm) {
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

	private var userInterfaceStylePickerForm: some View {
		EnumPickerForm(title: Text(L10n.AppSettings.UserInterfaceStyle.title), items: AppSettings.userInterfaceStyleAllCases, selection: $appSettings.userInterfaceStyle) { userInterfaceStyle, isSelected in
			HStack {
				Text(AppSettings.localizedTitle(for: userInterfaceStyle))
					.foregroundColor(Color(UIColor.label))
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
				}
			}
		}
	}

	private var feedbackSection: some View {
		Section {
			Button {
				let url = URL(string: "https://itunes.apple.com/app/id\(AppSettings.appStoreId)?action=write-review")!
				UIApplication.shared.open(url, options: [:])
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
					isPresentedMailComposeView = true
				} else {
					let url = URL(string: "mailto:\(AppSettings.feedbackMailAddress)?subject=\(feedbackMailSubject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)")!
					UIApplication.shared.open(url, options: [:])
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
				let url = URL(string: "https://apps.apple.com/developer/id\(AppSettings.developerId)")!
				UIApplication.shared.open(url, options: [:])
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

	// MARK: - Utilities
	private func circleColorView(for color: UIColor) -> some View {
		let showBorder = color == appSettings.globalTintColor

		return CircleColorView(
			showBorder: .constant(showBorder),
			buttonColor: Color(color),
			backgroundColor: Color(UIColor.tertiarySystemBackground),
			borderColor: Color(UIColor.separator)
		)
	}

	private func centeredView<Content: View>(content: (() -> Content)) -> some View {
		HStack(alignment: .center) {
			Spacer()
			content()
			Spacer()
		}
	}

	private var activityIndicatorRow: some View {
		centeredView {
			ActivityIndicator(isAnimating: .constant(true), style: .medium)
		}
	}
}

#if DEBUG
struct SettingsForm_Previews: PreviewProvider {
	static var previews: some View {
		SettingsForm()
	}
}
#endif
