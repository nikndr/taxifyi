//
//  GoogleRoutesApiHandler.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/3/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

class GoogleRoutesApiHandler {
	class func sendRoutesRequest(with args: [String: String], completionHandler: @escaping (JSON) -> Void) {
		let url = "https://maps.googleapis.com/maps/api/directions/json"
		let params = args as [String: Any]
		Alamofire.request(url, method: .get, parameters: params).responseString { response in
			switch response.result {
			case .success:
				guard let rawData = response.result.value else {
					return
				}
				completionHandler(JSON(parseJSON: rawData))
			case .failure:
				print("Error while getting routes: \(String(describing: response.result.error))")
			}
		}
	}
}

enum ApiKeys: String {
	case googleApiKey = "AIzaSyA9meYK6gmKQH40ntBEePNxP2IhCGGLSQw"
}
