//
//  ProfileViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/2/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Alamofire
import Firebase
import RealmSwift
import UIKit

class ProfileViewController: UIViewController, UserHolder {
	var lastSelectedIndex: Int?

	@IBOutlet var profileTableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		profileTableView.delegate = self
		profileTableView.dataSource = self
		profileTableView.tableFooterView = UIView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		profileTableView.reloadData()
		updateUserOnServer()
	}

	// MARK: - Actions

	@IBAction func doneButtonPressed(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func signOutButtonPressed(_ sender: UIButton) {
		do {
			try Auth.auth().signOut()
			performSegue(withIdentifier: "signOut", sender: self)
		} catch {
			print("error while sign out: \(error)")
		}
	}

	// MARK: - Networking

	func updateUserOnServer() {
		let user = getCurrentUser()!
		Auth.auth().currentUser?.updatePassword(to: user.password, completion: { error in
			print("error updating password: \(String(describing: error))\n")
		})
		let url = "https://taxifyi.lknmessenger.co/user/update"
		let args = [
			"email": user.email,
			"pass": user.password,
			"first_name": user.firstName,
			"last_name": user.lastName,
			"phone_number": user.phoneNumber,

		]
		Alamofire.request(url, method: .post, parameters: args).responseString { response in
			switch response.result{
			case .success:
				print("success updating user\n")
			case .failure:
				print("error updating user\n")
			}
		}
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "editProfileField" {
			guard let this = sender as? ProfileViewController else { return }
			let destination = segue.destination as! EditProfileFieldViewController
			guard let field = getFieldNameAndValue(byIndex: this.lastSelectedIndex!) else {
				return
			}
			destination.fieldName = field["field"]!
			destination.oldValue = field["value"]!
			destination.user = getCurrentUser()
		}
	}

	func getFieldNameAndValue(byIndex index: Int) -> [String: String?]? {
		let maybeUser = getCurrentUser()
		guard let user = maybeUser else {
			return nil
		}
		switch index {
		case 0:
			return ["field": "First Name", "value": user.firstName]
		case 1:
			return ["field": "Last Name", "value": user.lastName]
		case 2:
			return ["field": "Email", "value": user.email]
		case 3:
			return ["field": "Phone Number", "value": user.phoneNumber]
		case 4:
			return ["field": "Password", "value": ""]
		default:
			return nil
		}
	}
}

extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		lastSelectedIndex = indexPath.row
		if let field = getFieldNameAndValue(byIndex: lastSelectedIndex!) {
			if let name = field["field"] {
				if name != "Email" {
					performSegue(withIdentifier: "editProfileField", sender: self)
				}
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension ProfileViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		print("sections")
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? ProfileTableViewCell else {
			fatalError(#"unable to get cell with identifier "profileCell" "#)
		}
		let currentUser = getCurrentUser()
		switch indexPath.row {
		case 0:
			cell.title = "First Name"
			cell.value = currentUser?.firstName
		case 1:
			cell.title = "Last Name"
			cell.value = currentUser?.lastName
		case 2:
			cell.title = "Email"
			cell.value = currentUser?.email
		case 3:
			cell.title = "Phone Number"
			cell.value = currentUser?.phoneNumber
		case 4:
			cell.title = "Password"
			cell.value = "••••••"
		default:
			fatalError("unsupported cell index")
		}
		return cell
	}

	// MARK: - Database
}

protocol UserHolder {

}

extension UserHolder {
	func getCurrentUser() -> User? {
		if let email = Auth.auth().currentUser?.email {
			do {
				let realm = try Realm()
				let user = realm.objects(User.self).filter("email = '\(email)'").first
				return user
			} catch {
				print("error while getting user from realm: \(error)")
				return nil
			}
		}
		return nil
	}
}
