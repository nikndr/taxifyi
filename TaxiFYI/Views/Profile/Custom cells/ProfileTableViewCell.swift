//
//  ProfileTableViewCell.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/2/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
	@IBOutlet weak var cellTitleLabel: UILabel!
	@IBOutlet weak var cellValueLabel: UILabel!

	var title: String? {
		didSet {
			cellTitleLabel.text = title
		}
	}

	var value: String? {
		didSet {
			cellValueLabel.text = value
		}
	}

}
