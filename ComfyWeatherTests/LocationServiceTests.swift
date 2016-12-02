//
//  LocationServiceTests.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/17/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
@testable import ComfyWeather

class LocationServiceTests: XCTestCase {
    
    func testUpdateLocation() {
        let locationCambridge = CLLocation(latitude: 42.373616, longitude: -71.109734)
        let locationPaloAlto = CLLocation(latitude: 37.441883, longitude: -122.143019)
        let locationSanFrancisco = CLLocation(latitude: 37.774929, longitude: -122.419416)
        let locationBeijing = CLLocation(latitude: 39.904211, longitude: 116.407395)
        let locationLondon = CLLocation(latitude: 51.507351, longitude: -0.127758)
        let locations = [locationCambridge, locationPaloAlto, locationSanFrancisco, locationBeijing, locationLondon]
        
        for location in locations {
            LocationService.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: [location])
            XCTAssertEqual(LocationService.sharedInstance.lastLocation, location)
        }
        
        // Test that only the last location passed in is used
        LocationService.sharedInstance.locationManager(CLLocationManager(), didUpdateLocations: locations)
        XCTAssertNotEqual(LocationService.sharedInstance.lastLocation, locationCambridge)
        XCTAssertNotEqual(LocationService.sharedInstance.lastLocation, locationBeijing)
        
    }
    
}
