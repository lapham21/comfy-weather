//
//  WeatherAssetsViewModelTests.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import ComfyWeather

class WeatherAssetsViewModelTests: XCTestCase {

    func testTimeOfDay() {
        let eveningHour = [0, 1, 2, 3, 4, 5, 18, 19, 20, 21, 22, 23]
        for hour in eveningHour {
            XCTAssertEqual(TimeOfDay(hour: hour), .evening)
        }
        let morningHour = [6, 7, 8, 9, 10, 11]
        for hour in morningHour {
            XCTAssertEqual(TimeOfDay(hour: hour), .morning)
        }
        let afternoonHour = [6, 7, 8, 9, 10, 11]
        for hour in afternoonHour {
            XCTAssertEqual(TimeOfDay(hour: hour), .morning)
        }
    }

    func testConfigureWeatherAssets() {
        let viewModel = WeatherAssetsViewModel()
        guard let iconValue = viewModel.icon.value else {
            return
        }
        let timeOfDay = TimeOfDay(hour: Calendar.current.component(.hour, from: Date()))
        switch iconValue {
        case "clear-day":
            XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherDaySunny"))
            XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherDaySunnyHomeScreen"))
        case "clear-night":
            XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherNightSunny"))
            XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherNightSunnyHomeScreen"))
        case "rain", "snow", "sleet":
            XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherDayLightning"))
            XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherDayNightRainingHomeScreen"))
        case "wind":
            if timeOfDay == .morning || timeOfDay == .afternoon {
                XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherDayWindy"))
                XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherDayWindyHomeScreen"))
            } else {
                XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherNightWindy"))
                XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherNightWindyHomeScreen"))
            }
        case "partly-cloudy-day":
            XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherDayCloudy"))
            XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherDayCloudyHomeScreen"))
        case "partly-cloudy-night":
            XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherNightCloudy"))
            XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherNightCloudyHomeScreen"))
        case "fog", "cloudy":
            if timeOfDay == .morning || timeOfDay == .afternoon {
                XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherDayCloudy"))
                XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherDayCloudyHomeScreen"))
            } else {
                XCTAssertEqual(viewModel.weatherAddOutfit.value, #imageLiteral(resourceName: "weatherNightCloudy"))
                XCTAssertEqual(viewModel.weatherHomeScreen.value, #imageLiteral(resourceName: "weatherNightCloudyHomeScreen"))
            }
        default:
            break
        }
    }

}
