//
//  StoreProudct.swift
//  addressbook
//

enum StoreProduct: String, CaseIterable {
	case donate1 = "com.wincomi.ios.addressbook.inapp.donate1"
	case donate2 = "com.wincomi.ios.addressbook.inapp.donate2"
	case donate3 = "com.wincomi.ios.addressbook.inapp.donate3"
	case pro = "com.wincomi.ios.addressbook.inapp.pro"

	static let donateCases: [StoreProduct] = [.donate1, .donate2, .donate3]
}
