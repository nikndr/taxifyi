//
//  EditProfileFieldViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/5/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import RealmSwift
import SkyFloatingLabelTextField
import UIKit

class EditProfileFieldViewController: UIViewController {
	var fieldName: String!
	var oldValue: String!
	var user: User!
	var newValue: String! {
		didSet {
			do {
				let realm = try Realm()
				switch fieldName {
				case "First Name":
					try realm.write {
						user.firstName = newValue
					}
				case "Last Name":
					try realm.write {
						user.lastName = newValue
					}
				case "Phone Number":
					try realm.write {
						user.phoneNumber = newValue
					}
				case "Password":
					try realm.write {
						user.password = newValue
					}
				default:
					return
				}
			} catch {
				print("change profile realm error: \(error)")
			}
		}
	}

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var fieldNameLabel: UILabel!
	@IBOutlet var textField: SkyFloatingLabelTextField!

	override func viewDidLoad() {
		super.viewDidLoad()

		titleLabel.text = "Edit \(fieldName!)"
		fieldNameLabel.text = fieldName
		textField.text = oldValue
	}

	@IBAction func saveChangesButtonClicked(_ sender: UIButton) {
		if let text = textField.text {
			if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
				newValue = text
			}
		}
		dismiss(animated: true, completion: nil)
	}
}
