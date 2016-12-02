//
//  WeatherTypeViewModelTests.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/13/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import ComfyWeather

class WeatherTypeViewModelTests: XCTestCase {

    func testInitializeChilly() {
        let viewModel = WeatherTypeViewModel(weatherType: .chilly)

        if viewModel.weatherType == .chilly &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortChilly") &&
            viewModel.weatherText == "Chilly" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

    func testInitializeComfy() {
        let viewModel = WeatherTypeViewModel(weatherType: .comfy)

        if viewModel.weatherType == .comfy &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortComfy") &&
            viewModel.weatherText == "Comfy" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

    func testInitializeToasty() {
        let viewModel = WeatherTypeViewModel(weatherType: .toasty)

        if viewModel.weatherType == .toasty &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortToasty") &&
            viewModel.weatherText == "Toasty" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

    func testComfortabilityButtonSelectedForChilly() {
        let viewModel = WeatherTypeViewModel(weatherType: .chilly)
        viewModel.isSelected = true
        viewModel.comfortabilityButtonSelected()

        if viewModel.weatherType == .chilly &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortChillySelected") &&
            viewModel.weatherText == "Chilly" &&
            viewModel.isSelected == true {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

    func testComfortabilityButtonSelectedForComfy() {
        let viewModel = WeatherTypeViewModel(weatherType: .comfy)
        viewModel.isSelected = true
        viewModel.comfortabilityButtonSelected()

        if viewModel.weatherType == .comfy &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortComfySelected") &&
            viewModel.weatherText == "Comfy" &&
            viewModel.isSelected == true {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

    func testComfortabilityButtonSelectedForToasty() {
        let viewModel = WeatherTypeViewModel(weatherType: .toasty)
        viewModel.isSelected = true
        viewModel.comfortabilityButtonSelected()

        if viewModel.weatherType == .toasty &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortToastySelected") &&
            viewModel.weatherText == "Toasty" &&
            viewModel.isSelected == true {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }
    
    func testReverseComfortabilityButtonSelectedForChilly() {
        let viewModel = WeatherTypeViewModel(weatherType: .chilly)
        viewModel.isSelected = false
        viewModel.comfortabilityButtonSelected()
        
        if viewModel.weatherType == .chilly &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortChilly") &&
            viewModel.weatherText == "Chilly" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }
    
    func testReverseComfortabilityButtonSelectedForComfy() {
        let viewModel = WeatherTypeViewModel(weatherType: .comfy)
        viewModel.isSelected = false
        viewModel.comfortabilityButtonSelected()
        
        if viewModel.weatherType == .comfy &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortComfy") &&
            viewModel.weatherText == "Comfy" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }
    
    func testReverseComfortabilityButtonSelectedForToasty() {
        let viewModel = WeatherTypeViewModel(weatherType: .toasty)
        viewModel.isSelected = false
        viewModel.comfortabilityButtonSelected()
        
        if viewModel.weatherType == .toasty &&
            viewModel.weatherImage.value == #imageLiteral(resourceName: "comfortToasty") &&
            viewModel.weatherText == "Toasty" &&
            viewModel.isSelected == false {
            XCTAssert(true, "Initalized successfully")
        } else {
            XCTAssert(false, "WeatherTypeViewModel not initialized correctly")
        }
    }

}
