//
//  UIViewControllerExtensions.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/30/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import UIKit

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
