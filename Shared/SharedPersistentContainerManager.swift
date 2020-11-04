//
//  SharedPersistentContainerManager.swift
//  addressbook
//

import CoreData

final class SharedPersistentContainerManager {
	static let shared = SharedPersistentContainerManager()

	private init() {}

	// MARK: - Core Data Stack
	lazy var persistentContainer: NSPersistentContainer = {
		let momdName = "SharedPersistentContainer"
		let groupName = "group.com.wincomi.addressbook"
		let fileName = "SharedPersistentContainer.sqlite"

		guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension: "momd") else {
			fatalError("Error loading model from bundle")
		}

		guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
			fatalError("Error initializing momd from: \(modelURL)")
		}

		guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) else {
			fatalError("Error creating base URL for \(groupName)")
		}

		let container = NSPersistentContainer(name: momdName, managedObjectModel: managedObjectModel)

		let storeDescription = NSPersistentStoreDescription()
		let storeUrl = baseURL.appendingPathComponent(fileName)
		storeDescription.url = storeUrl

		container.persistentStoreDescriptions = [storeDescription]
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}

		return container
	}()

	var context: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	func saveContext() {
		let context = persistentContainer.viewContext

		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
		do {
			let fetchResult = try context.fetch(request)
			return fetchResult
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}

	func delete(_ object: NSManagedObject)  {
		context.delete(object)
		do {
			try context.save()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}

	// MARK: - Managing CallDirectoryEntry
	func createCallDirectoryEntry(isBlocked: Bool, name: String, phoneNumber: Int64) {
		let callDirectoryEntry = CallDirectoryEntry(context: SharedPersistentContainerManager.shared.context)
		callDirectoryEntry.name = name
		callDirectoryEntry.phoneNumber = phoneNumber
		callDirectoryEntry.isBlocked = isBlocked
		callDirectoryEntry.isRemoved = false
		callDirectoryEntry.updatedDate = Date()

		saveContext()
	}

	func edit(_ callDirectoryEntry: CallDirectoryEntry, configureCallDirectoryEntry: ((CallDirectoryEntry) -> Void)) {
		configureCallDirectoryEntry(callDirectoryEntry)
		callDirectoryEntry.updatedDate = Date()

		saveContext()
	}

	func remove(_ callDirectoryEntry: CallDirectoryEntry) {
		callDirectoryEntry.isRemoved = true
		callDirectoryEntry.updatedDate = Date()

		saveContext()
	}

	func cleanCallDirectoryEntries() {
		let fetchRequest: NSFetchRequest<CallDirectoryEntry> = CallDirectoryEntry.fetchRequest()
		let isRemovedPredicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: true))
		fetchRequest.predicate = isRemovedPredicate

		do {
			let removedCallDirectoryEntries = try context.fetch(fetchRequest)
			removedCallDirectoryEntries.forEach {
				delete($0)
			}

			saveContext()
		} catch {
			let nserror = error as NSError
			fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
}
