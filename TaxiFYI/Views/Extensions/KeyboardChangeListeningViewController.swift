//
//  KeyboardChangeListeningViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/30/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import UIKit

// TODO: - Remove. Class is not used
class KeyboardChangeListeningViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@objc public func keyboardWillChange(notification: Notification) {
		guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
			fatalError("Keyboard not found")
		}
		if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
			view.frame.origin.y = -keyboardRect.height
		} else if notification.name == UIResponder.keyboardWillHideNotification {
			view.frame.origin.y = 0
		}
	}

	public func addKeyboardObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	public func removeKeyboardObservers() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}
}
