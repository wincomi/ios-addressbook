//
//  ContactStore.swift
//  addressbook
//

import Contacts
import ContactsUI

final class ContactStore {
	static let didChange = NotificationCenter.default.publisher(for: .CNContactStoreDidChange).map { _ in }
	static let shared = ContactStore()

	private init() { }

	private let store = CNContactStore()

	// MARK: - Requesting Access to the User's Contacts

	/// 연락처 접근 권한 요청
	class func requestAuthorization(_ handler: @escaping (CNAuthorizationStatus) -> Void) {
		CNContactStore().requestAccess(for: .contacts) { (granted, error) in
			guard !granted, error != nil else {
				handler(.notDetermined)
				return
			}

			handler(CNContactStore.authorizationStatus(for: .contacts))
		}
	}

	/// 현재 접근 권한 상태
	static var authorizationStatus: CNAuthorizationStatus {
		CNContactStore.authorizationStatus(for: .contacts)
	}

	// MARK: - Fetching Contacts

	/// 연락처 가져오기
	public func fetchContacts(matching predicate: NSPredicate) throws -> [CNContact] {
		let keysToFetch: [CNKeyDescriptor] = [
			CNContactViewController.descriptorForRequiredKeys(),
			CNContactVCardSerialization.descriptorForRequiredKeys()
		]

		let request = CNContactFetchRequest(keysToFetch: keysToFetch)
		request.predicate = predicate
		request.unifyResults = true

		do {
			var contacts = [CNContact]()
			try store.enumerateContacts(with: request, usingBlock: { (contact, _) in
				contacts.append(contact)
			})
			return contacts
		} catch {
			throw error
		}
	}

	/// 모든 연락처 가져오기
	public func fetchContacts() throws -> [CNContact] {
		let keysToFetch: [CNKeyDescriptor] = [
			CNContactViewController.descriptorForRequiredKeys(),
			CNContactVCardSerialization.descriptorForRequiredKeys()
		]
		
		let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
		
		do {
			var contacts = [CNContact]()
			try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) in
				contacts.append(contact)
			})
			return contacts
		} catch {
			throw error
		}
	}

	/// Fetching contacts with contact identifiers
	public func fetchContacts(withIdentifier identifiers: [String]) throws -> [CNContact] {
		let predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)

		do {
			return try fetchContacts(matching: predicate)
		} catch {
			throw error
		}
	}

	public func fetchContacts(matchingName name: String) throws -> [CNContact] {
		let predicate = CNContact.predicateForContacts(matchingName: name)

		do {
			return try fetchContacts(matching: predicate)
		} catch {
			throw error
		}
	}

	/// 컨테이너에 있는 연락처 가져오기
	public func fetchContacts(in container: CNContainer?) throws -> [CNContact] {
		guard let container = container else {
			return try fetchContacts()
		}

		let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
		
		do {
			return try fetchContacts(matching: predicate)
		} catch {
			throw error
		}
	}

	/// 그룹에 있는 연락처 가져오기
	public func fetchContacts(in group: CNGroup?) throws -> [CNContact] {
		guard let group = group else {
			return try fetchContacts()
		}

		let predicate = CNContact.predicateForContactsInGroup(withIdentifier: group.identifier)

		do {
			return try fetchContacts(matching: predicate)
		} catch {
			throw error
		}
	}

	// MARK: - Fetching Containers

	// 모든 컨테이너 가져오기
	public func fetchContainers(matching: NSPredicate? = nil) throws -> [CNContainer] {
		do {
			return try store.containers(matching: matching)
		} catch {
			throw error
		}
	}

	// MARK: - Fetching Groups
	//// Fetching all groups
	public func fetchGroups() throws -> [CNGroup] {
		do {
			return try store.groups(matching: nil)
		} catch {
			throw error
		}
	}

	/// Fetching groups with group identifiers
	public func fetchGroups(withIdentifiers identifiers: [String]) throws -> [CNGroup] {
		let predicate = CNGroup.predicateForGroups(withIdentifiers: identifiers)

		do {
			return try store.groups(matching: predicate)
		} catch {
			throw error
		}
	}

	/// 모든 연락처 그룹 가져오기
	public func fetchGroups(in container: CNContainer) throws -> [CNGroup] {
		let predicate = CNGroup.predicateForGroupsInContainer(withIdentifier: container.identifier)
		
		do {
			return try store.groups(matching: predicate)
		} catch {
			throw error
		}
	}

	// MARK: - Managing Groups
	// 컨테이너에 새 그룹 만들기
	public func create(group configureGroup: ((CNMutableGroup) -> Void), to container: CNContainer) throws {
		let groupToCreate = CNMutableGroup()
		configureGroup(groupToCreate)

		let request = CNSaveRequest()
		request.add(groupToCreate, toContainerWithIdentifier: container.identifier)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}

	/// 그룹 삭제
	public func delete(_ group: CNGroup) throws {
		guard let mutableGroup = group.mutableCopy() as? CNMutableGroup else {
			fatalError()
		}

		let request = CNSaveRequest()
		request.delete(mutableGroup)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}


	// MARK: - Managing Contacts
	/// 컨테이너에 새 연락처 만들기
	public func create(contact configureContact: ((CNMutableContact) -> Void), to container: CNContainer) throws {
		let contactToCreate = CNMutableContact()
		configureContact(contactToCreate)

		let request = CNSaveRequest()
		request.add(contactToCreate, toContainerWithIdentifier: container.identifier)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}

	/// 연락처를 삭제한다.
	public func delete(_ contact: CNContact) throws {
		guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
			fatalError()
		}

		let request = CNSaveRequest()
		request.delete(mutableContact)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}

	/// 연락처를 그룹에 추가한다.
	public func add(_ contact: CNContact, to group: CNGroup) throws {
		guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
			fatalError()
		}

		let request = CNSaveRequest()
		request.addMember(mutableContact, to: group)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}

	/// 연락처를 그룹에서 제거한다.
	public func remove(_ contact: CNContact, from group: CNGroup) throws {
		guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
			fatalError()
		}

		let request = CNSaveRequest()
		request.removeMember(mutableContact, from: group)

		do {
			try store.execute(request)
		} catch {
			throw error
		}
	}
}

extension CNContact {
	/// 연락처를 수정한다.
	public func update(_ updateContact: ((CNMutableContact) -> Void)) throws {
		guard let contactToUpdate = self.mutableCopy() as? CNMutableContact else { fatalError() }

		updateContact(contactToUpdate)

		let request = CNSaveRequest()
		request.update(contactToUpdate)

		do {
			try CNContactStore().execute(request)
		} catch {
			throw error
		}
	}
}

extension CNGroup {
	/// 그룹의 이름을 업데이트 한다.
	public func update(_ updateGroup: ((CNMutableGroup) -> Void)) throws {
		guard let groupToUpdate = self.mutableCopy() as? CNMutableGroup else { fatalError() }

		updateGroup(groupToUpdate)

		let request = CNSaveRequest()
		request.update(groupToUpdate)

		do {
			try CNContactStore().execute(request)
		} catch {
			throw error
		}
	}
}
