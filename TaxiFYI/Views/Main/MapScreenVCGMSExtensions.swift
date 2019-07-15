//
//  MapScreenVCGMSExtensions.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 5/3/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import UIKit

extension MapScreenViewController: GMSAutocompleteViewControllerDelegate {
	func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
		print("found place: \(place)")
		print("selected point: \(self.selectedPointOfRide!)")
		geocoder.reverseGeocodeCoordinate(place.coordinate) { response, error in
			guard error == nil else { return }
			let location = response?.firstResult()
			switch self.selectedPointOfRide! {
			case .from:
				self.addressFrom = location
			case .to:
				self.addressTo = location
			}
		}
		dismiss(animated: true, completion: nil)
	}

	func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
		// TODO: handle the error.
		print("Error: ", error.localizedDescription)
	}

	func wasCancelled(_ viewController: GMSAutocompleteViewController) {
		dismiss(animated: true, completion: nil)
	}

	// Turn the network activity indicator on and off again.
	func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}

	func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}

extension MapScreenViewController: CLLocationManagerDelegate {
	// MARK: - CLLocationManagerDelegate extension methods

	// Handle incoming location events.
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location: CLLocation = locations.last!
		print("Location: \(location)")

		let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
		                                      longitude: location.coordinate.longitude,
		                                      zoom: zoomLevel)

		if mapView.isHidden {
			print("updating location")
			mapView.isHidden = false
			mapView.camera = camera
		} else {
			mapView.animate(to: camera)
		}
	}

	// Handle authorization for the location manager.
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .restricted:
			print("Location access was restricted.")
		case .denied:
			print("User denied access to location.")
			// Display the map using the default location.
			mapView.isHidden = false
		case .notDetermined:
			print("Location status not determined.")
		case .authorizedAlways: fallthrough
		case .authorizedWhenInUse:
			print("Location status is OK.")
		@unknown default:
			print("location access is undefined")
		}
	}

	// Handle location manager errors.
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		locationManager.stopUpdatingLocation()
		print("Error: \(error)")
	}
}

extension MapScreenViewController: GMSMapViewDelegate {
	func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//		usedManualLocationForFromPoint = false
	}

	func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
		geocoder.reverseGeocodeCoordinate(position.target) { response, error in
			guard error == nil else { return }
			if /*!self.usedManualLocationForFromPoint &&*/ self.receiveMapMoveUpdates {
				if let result = response?.firstResult() {
					self.addressFrom = result
				} else {
					self.addressFrom = nil
				}
			}
		}
	}
}
