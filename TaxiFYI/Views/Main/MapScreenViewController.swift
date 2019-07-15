//
//  MapScreenViewController.swift
//  TaxiFYI
//
//  Created by Nikandr Margal on 4/30/19.
//  Copyright © 2019 Nikandr Marhal. All rights reserved.
//

import Alamofire
import GoogleMaps
import GooglePlaces
import RealmSwift
import SwiftyJSON
import UIKit

class MapScreenViewController: UIViewController, UserHolder {
	// MARK: - Outlets

	@IBOutlet var mapView: GMSMapView!
	@IBOutlet var addressFromLabel: UILabel!
	@IBOutlet var addressToLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var rideDetailsView: UIView!
	@IBOutlet var rideButton: UIButton!

	var locationManager: CLLocationManager!
	var currentLocation: CLLocation?
	var placesClient: GMSPlacesClient!
	var geocoder: GMSGeocoder!
	var zoomLevel: Float!

	var selectedPointOfRide: SelectedPointOfRide!
//	var usedManualLocationForFromPoint = false
	var receiveMapMoveUpdates = true

	var addressFrom: GMSAddress? {
		didSet {
			print("addres from")
			addressFromLabel.text = addressFrom?.lines?.joined(separator: ",") ?? ""
		}
	}

	var addressTo: GMSAddress? {
		didSet {
			addressToLabel.text = addressTo?.lines?.joined(separator: ",") ?? ""
			getRouteData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		zoomLevel = 17.0
		configureLocationManager()

		placesClient = GMSPlacesClient.shared()
		geocoder = GMSGeocoder()

		configureMapView()
		applyCustomStyling()

		rideDetailsView.isHidden = true
		rideButton.isHidden = true
	}

	// MARK: - Actions

	@IBAction func wannaRideButtonPressed(_ sender: UIButton) {
		let ride = getRide()!
		let url = "https://taxifyi.lknmessenger.co/ride/create"
		let parameters: [String: Any] = [
			"start": "\(ride.start)",
			"end": "\(ride.end)",
			"distance": ride.distance,
			"price": ride.price,
			"time": ride.time,
			"email": ride.email,
		]

		Alamofire.request(url, method: .post, parameters: parameters, encoding: Alamofire.JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
			switch response.result {
			case .success(let value):
				let json = JSON(value)
				print(json["ride"]["car_description"])
				guard let description = json["ride"]["car_description"].string else { return }
				self.showAlert(withTitle: "Ride Found!", text: description) { _ in
					self.refresh()
				}
			case .failure:
				print("Error while getting routes: \(String(describing: response.result.error))")
			}
		}
	}

	@IBAction func refreshButtonPressed(_ sender: UIButton) {
		refresh()
	}

	func refresh() {
		mapView.clear()
		receiveMapMoveUpdates = true
		addressFrom = nil
		addressTo = nil
		rideDetailsView.isHidden = true
		rideButton.isHidden = true
	}

	// MARK: - Gestures

	@IBAction func locationFromViewTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			selectedPointOfRide = .from
			receiveMapMoveUpdates = false
			presentAutocompleteViewController()
		}
	}

	@IBAction func locationToViewTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			selectedPointOfRide = .to
			presentAutocompleteViewController()
		}
	}

	// MARK: - Networking

	func getRouteData() {
		guard let from = addressFrom?.coordinate, let to = addressTo?.coordinate else {
			return
		}
		let requestArgs = [
			"origin": "\(from.latitude),\(from.longitude)",
			"destination": "\(to.latitude),\(to.longitude)",
			"key": ApiKeys.googleApiKey.rawValue,
		]
		GoogleRoutesApiHandler.sendRoutesRequest(with: requestArgs) { data in
			self.receiveMapMoveUpdates = false

			let ride = Ride()
			let routes = data["routes"][0]
			let legs = routes["legs"][0]
			let points = routes["overview_polyline"]["points"]
			let distanceInMeters = legs["distance"]["value"].number!.intValue
			let timeInSeconds = legs["duration"]["value"].number!.intValue
			let price = self.calculatePrice(dist: distanceInMeters, duration: timeInSeconds)

			ride.email = self.getCurrentUser()!.email
			ride.distance = distanceInMeters
			ride.time = timeInSeconds
			ride.price = price
			ride.start = "\(self.addressFrom!.coordinate.latitude),\(self.addressFrom!.coordinate.longitude)"
			ride.end = "\(self.addressTo!.coordinate.latitude),\(self.addressTo!.coordinate.longitude)"
			self.addRide(ride: ride)

			self.distanceLabel.text = "\(distanceInMeters / 1000)km"
			self.timeLabel.text = "\(timeInSeconds / 60) min"
			self.priceLabel.text = String(format: "%.2f", price)

			self.rideDetailsView.isHidden = false
			self.rideButton.isHidden = false
			self.drawRoute(from: points.string!)
		}
	}

	func calculatePrice(dist: Int, duration: Int) -> Float {
		let price = Float(dist / 1000) * 7 + Float(duration) / 100
		return price < 30 ? 30 : price
	}

	// MARK: - Database

	func addRide(ride: Ride) {
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(ride, update: false)
			}
		} catch {
			print("error creating ride: \(error)")
		}
	}

	func getRide() -> Ride? {
		var res: Ride?
		do {
			let realm = try Realm()
			res = realm.objects(Ride.self).sorted(byKeyPath: "createdAt").first
		} catch {
			print("error getting ride: \(error)")
		}
		return res
	}

	// MARK: - Location configuration

	func configureLocationManager() {
		locationManager = CLLocationManager()
		locationManager.requestAlwaysAuthorization()
		locationManager.distanceFilter = 50

		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.startUpdatingLocation()
		}
	}

	// MARK: - Map Configuration

	func configureMapView() {
		let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
		mapView.camera = camera
		mapView.delegate = self
		mapView.settings.myLocationButton = true
		mapView.settings.compassButton = true
		mapView.isMyLocationEnabled = true
		mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		mapView.isHidden = true // until we'll get location updates
	}

	func presentAutocompleteViewController() {
		let autocompleteController = GMSAutocompleteViewController()
		autocompleteController.delegate = self

		// Specify the place data types to return.
		let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.all.rawValue))!
		autocompleteController.placeFields = fields

		// Specify a filter.
		let filter = GMSAutocompleteFilter()
		filter.type = .address
		autocompleteController.autocompleteFilter = filter

		let neBoundsCorner = CLLocationCoordinate2D(latitude: 50.579350, longitude: 30.822270)
		let swBoundsCorner = CLLocationCoordinate2D(latitude: 50.202479, longitude: 30.189852)
		let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner) // Kyiv area
		autocompleteController.autocompleteBounds = bounds
		autocompleteController.autocompleteBoundsMode = .restrict

		// Display the autocomplete view controller.
		present(autocompleteController, animated: true, completion: nil)
	}

	func drawRoute(from path: String) {
		mapView.clear()
		if let path = GMSPath(fromEncodedPath: path) {
			let direction = GMSPolyline(path: path)
			direction.strokeWidth = 2
			direction.map = mapView
			drawMarkers()
			positionCameraAroundRoute(with: path)
		}
	}

	func positionCameraAroundRoute(with path: GMSPath) {
		let bounds = GMSCoordinateBounds(path: path)
		let camera = mapView.camera(for: bounds, insets: UIEdgeInsets())!
		mapView.animate(to: camera)
	}

	func drawMarkers() {
		let startMarker = GMSMarker(position: addressFrom!.coordinate)
		let endMarker = GMSMarker(position: addressTo!.coordinate)
		startMarker.title = "Start"
		endMarker.title = "End"
		startMarker.map = mapView
		endMarker.map = mapView
	}
}

extension MapScreenViewController {
	// MARK: - Design

	private func applyCustomStyling() {
		changeButtonsDesign()
		changeDirectionsDesign()
	}

	private func changeButtonsDesign() {}

	private func changeDirectionsDesign() {}
}
