//
//  GroupListSection.swift
//  addressbook
//

import Foundation
import Contacts

struct GroupListSection: SectionRepresentable, Identifiable, Hashable {
	enum `Type`: Hashable {
		case allContacts(in: CNContainer?)
		case group(in: CNContainer)
	}

	let type: Type

	// MARK: - SectionRepresentable
	let headerText: String?
	let footerText: String?
	let rows: [GroupListRow]

	// MARK: - Identifiable
	let id: Type

	// MARK: - Hashable
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	// MARK: - Making GroupListSection
	static func allContacts(in container: CNContainer? = nil) -> GroupListSection {
		GroupListSection(type: .allContacts(in: container), rows: [.allContacts(in: container)])
	}

	static func makeSections(from containers: [CNContainer], withAllContactsSection insertingAllContactsSection: Bool = false, withAllContactsRow insertingAllContactsRow: Bool = false) throws -> [GroupListSection] {
		do {
			var sections = try containers.map { container in
				try GroupListSection(from: container, withAllContactsRow: insertingAllContactsRow)
			}

			if insertingAllContactsSection {
				sections.insert(.allContacts(), at: 0)
			}

			return sections
		} catch {
			throw error
		}
	}

	// MARK: - Initialization
	public init(from container: CNContainer, withAllContactsRow insertingAllContactsRow: Bool = false) throws {
		let groups = try ContactStore.shared.fetchGroups(in: container)

		var rows = groups
			.map(GroupListRow.init)
			.sorted { $0.text.localizedCompare($1.text) == .orderedAscending }

		if insertingAllContactsRow {
			rows.insert(.allContacts(in: container), at: 0)
		}

		self.init(type: .group(in: container), rows: rows)
	}

	private init(type: Type, rows: [GroupListRow]) {
		self.type = type
		self.headerText = {
			switch type {
			case .allContacts:
				return nil
			case .group(in: let container):
				return container.displayName
			}
		}()
		self.footerText = nil
		self.rows = rows

		self.id = type
	}
}
