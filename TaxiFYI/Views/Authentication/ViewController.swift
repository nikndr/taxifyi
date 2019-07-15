//
//  ViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/21/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Firebase
import SVProgressHUD
import UIKit

class ViewController: UIViewController {
	@IBOutlet var signInButton: UIButton!
	@IBOutlet var createAccountButton: UIButton!
	@IBOutlet var mailTextField: UITextField!
	@IBOutlet var passwordTextField: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		SVProgressHUD.setDefaultStyle(.dark)
		applyCustomStyling()

		assignTextFieldDelegates()

		hideKeyboardWhenTappedAround()
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showMapsView" {
			print("showing maps")
		}
	}

	// MARK: - Button Actions

	@IBAction func signInButtonPressed(_ sender: UIButton) {
		SVProgressHUD.show()
		if let email = mailTextField.text, let password = passwordTextField.text {
			Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
				guard let strongSelf = self else {
					SVProgressHUD.dismiss()
					return
				}
				guard error == nil else {
					SVProgressHUD.dismiss()
					strongSelf.showAlert(withTitle: "Error", text: "Login error. Try with another email or password", handler: nil)
					return
				}
				SVProgressHUD.dismiss()
				strongSelf.performSegue(withIdentifier: "showMapsView", sender: strongSelf)
			}
		}
//		performSegue(withIdentifier: "showMapsView", sender: self)
	}

	@IBAction func createAccountButtonPressed(_ sender: UIButton) {
		print("new account")
	}

	// MARK: - Design

	private func applyCustomStyling() {
		changeButtonsDesign()
	}

	private func changeButtonsDesign() {
		signInButton.layer.cornerRadius = signInButton.frame.height / 2
		signInButton.layer.shadowOpacity = 0.2
		signInButton.layer.shadowOffset = CGSize(width: 0, height: 0)

		createAccountButton.layer.cornerRadius = createAccountButton.frame.height / 2
		createAccountButton.layer.shadowOpacity = 0.2
		createAccountButton.layer.shadowOffset = CGSize(width: 0, height: 0)
	}

	private func changeTextFieldsDesign() {}

	// MARK: - Database
}

// MARK: - Text Field Delegate Methods

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return false
	}

	func assignTextFieldDelegates() {
		mailTextField.delegate = self
		passwordTextField.delegate = self
	}
}

extension UIViewController {
	func showAlert(withTitle title: String, text: String, handler: ((UIAlertAction) -> Void)?) {
		let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
		present(alert, animated: true)
	}
}
