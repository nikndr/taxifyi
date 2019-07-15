//
//  Ride.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/3/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Foundation
import GoogleMaps
import RealmSwift

class Ride: Object {
	@objc dynamic var start = ""
	@objc dynamic var end = ""
	@objc dynamic var distance = 0
	@objc dynamic var time = 0
	@objc dynamic var price = Float()
	@objc dynamic var email = ""
	@objc dynamic var createdAt = Date()
}
