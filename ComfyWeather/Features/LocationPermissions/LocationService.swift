//
//  LocationService.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/11/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import CoreLocation
import RxSwift

protocol LocationServiceDelegate: class {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

final class LocationService: NSObject, CLLocationManagerDelegate {

    static let sharedInstance: LocationService = {
        return LocationService()
    }()

    private var locationManager = CLLocationManager()
    private(set) var lastLocation: CLLocation?
    private(set) var lastGeoCode: String?
    weak var delegate: LocationServiceDelegate?
    private(set) var isAuthorized: Bool = false

    private(set) var geoLocation = Variable(Result.success(""))
    lazy var geoLocationObservable: Observable<Result<String>>
        = {
            return self.geoLocation.asObservable()
        }()

    override init() {
        super.init()

        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 500
    }

    func startUpdatingLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if !(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        self.lastLocation = location

        updateLocation(currentLocation: location)

        let fetchWeatherService = FetchWeatherService.sharedInstance
        fetchWeatherService.requestForecasts()

        getGeoCode()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationDidFailWithError(error: error as NSError)
    }

    private func updateLocation(currentLocation: CLLocation){
        delegate?.tracingLocation(currentLocation: currentLocation)
    }

    private func updateLocationDidFailWithError(error: NSError) {
        delegate?.tracingLocationDidFailWithError(error: error)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }

    // MARK: GeoCode

    private func getGeoCode() {
        guard let location = lastLocation else {return}
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                self?.geoLocation.value = .failure(error)
                return
            }

            guard let placemark = placemarks?.first,
                let locality = placemark.locality,
                let administrativeArea = placemark.administrativeArea
                else {return}
            self?.lastGeoCode = "\(locality), \(administrativeArea)"
            self?.geoLocation.value = .success(self?.lastGeoCode ?? "")
        }
    }

    func reverseGeoCode(for location: CLLocation, completion: @escaping (Result<String>) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard
                    let placemark = placemarks?.first,
                    let locality = placemark.locality,
                    let administrativeArea = placemark.administrativeArea
                    else { return }
                let geoCode = "\(locality), \(administrativeArea)"
                completion(.success(geoCode))
            }
        }
    }
}
