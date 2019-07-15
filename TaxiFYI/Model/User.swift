//
//  User.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/2/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
	@objc dynamic var firstName = ""
	@objc dynamic var lastName = ""
	@objc dynamic var email = ""
	@objc dynamic var phoneNumber = ""
	@objc dynamic var password = ""

	override class func primaryKey() -> String? {
		return "email"
	}
}
