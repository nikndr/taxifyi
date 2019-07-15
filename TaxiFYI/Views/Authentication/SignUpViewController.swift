//
//  SignUpViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/30/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Firebase
import RealmSwift
import SkyFloatingLabelTextField
import UIKit

class SignUpViewController: UIViewController {
	@IBOutlet var signUpButton: UIButton!
	@IBOutlet var haveAnAccountButton: UIButton!

	@IBOutlet var firstNameTextField: SkyFloatingLabelTextField!
	@IBOutlet var lastNameTextField: SkyFloatingLabelTextField!
	@IBOutlet var emailTextField: SkyFloatingLabelTextField!
	@IBOutlet var phoneNumberTextField: SkyFloatingLabelTextField!
	@IBOutlet var passwordTextField: SkyFloatingLabelTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		applyCustomStyling()
		hideKeyboardWhenTappedAround()
		assignTextFieldDelegates()
	}

	// MARK: - Button Actions

	@IBAction func signUpButtonPressed(_ sender: UIButton) {
		if let firstName = firstNameTextField.text,
			let lastName = lastNameTextField.text,
			let email = emailTextField.text,
			let password = passwordTextField.text,
			let phoneNumber = phoneNumberTextField.text {
			Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
				guard error == nil else {
					print(error)
					self.showAlert(withTitle: "Error", text: "Sign up error. Email is taken", handler: nil)
					return
				}
				guard let result = authResult else {
					print("no auth")
					return
				}
				self.saveToDb(user: User(value: [firstName, lastName, email, phoneNumber, password]))
				self.performSegue(withIdentifier: "showMapsViewFromSignUp", sender: self)
			}
		}
	}

	@IBAction func haveAnAccountButtonPressed(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}

	// MARK: - Design

	func applyCustomStyling() {
		changeButtonDesign()
	}

	func changeButtonDesign() {
		signUpButton.layer.cornerRadius = signUpButton.frame.height / 2
		signUpButton.layer.shadowOpacity = 0.2
		signUpButton.layer.shadowOffset = CGSize(width: 0, height: 0)

		haveAnAccountButton.layer.cornerRadius = haveAnAccountButton.frame.height / 2
		haveAnAccountButton.layer.shadowOpacity = 0.2
		haveAnAccountButton.layer.shadowOffset = CGSize(width: 0, height: 0)
	}

	//MARK: - Realm

	func saveToDb(user: User) {
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(user)
			}
		} catch {
			print("realm error sign in: \(error)")
		}
	}
}

extension SignUpViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return false
	}

	func assignTextFieldDelegates() {
		firstNameTextField.delegate = self
		lastNameTextField.delegate = self
		emailTextField.delegate = self
		phoneNumberTextField.delegate = self
		passwordTextField.delegate = self
	}
}

