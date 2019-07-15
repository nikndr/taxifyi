//
//  AppDelegate.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/21/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		GMSServices.provideAPIKey(ApiKeys.googleApiKey.rawValue)
		GMSPlacesClient.provideAPIKey(ApiKeys.googleApiKey.rawValue)
		do {
			_ = try Realm()
		} catch {
			print("Error initializing Realm: \(error)")
		}
		return true
	}
}

