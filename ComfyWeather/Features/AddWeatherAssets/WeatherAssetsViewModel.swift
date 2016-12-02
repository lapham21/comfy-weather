//
//  WeatherAssetsViewModel.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/20/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift

enum TimeOfDay {
    case morning
    case afternoon
    case evening

    init? (hour: Int) {
        switch hour {
        case 6...11:
            self = .morning
        case 12...17:
            self = .afternoon
        default:
            self = .evening
        }
    }
}

final class WeatherAssetsViewModel {

    //MARK: Enums and Variables

    enum IconResult {
        case sunnyDay
        case sunnyNight
        case cloudyDay
        case cloudyNight
        case raining
        case windyDay
        case windyNight

        init?(string: String?, timeOfDay: TimeOfDay?) {
            guard let string = string else { return nil }

            switch string {
            case "clear-night":
                self = .sunnyNight
            case "rain", "snow", "sleet":
                self = .raining
            case "wind":
                if timeOfDay == .morning || timeOfDay == .afternoon {
                    self = .windyDay
                } else {
                    self = .windyNight
                }
            case "partly-cloudy-day":
                self = .cloudyDay
            case "partly-cloudy-night":
                self = .cloudyNight
            case "fog", "cloudy":
                if timeOfDay == .morning || timeOfDay == .afternoon {
                    self = .cloudyDay
                } else {
                    self = .cloudyNight
                }
            default:
                self = .sunnyDay
            }
        }
    }

    var icon = Variable<String?>(nil)
    var weatherHomeScreen = Variable<UIImage?>(nil)
    var weatherAddOutfit = Variable<UIImage?>(nil)

    private let disposeBag = DisposeBag()

    //MARK: Initialization

    init(icon anIcon: String? = nil) {
        let hour = Calendar.current.component(.hour, from: Date())
        var timeOfDay = TimeOfDay(hour: hour) ?? .afternoon

        if anIcon == nil {

            switch timeOfDay {
            case .morning:
                FetchWeatherService.sharedInstance.morningWeatherModelObservable.map {$0?.icon}.bindTo(icon).addDisposableTo(disposeBag)
            case .afternoon:
                FetchWeatherService.sharedInstance.afternoonWeatherModelObservable.map {$0?.icon}.bindTo(icon).addDisposableTo(disposeBag)
            default:
                FetchWeatherService.sharedInstance.eveningWeatherModelObservable.map {$0?.icon}.bindTo(icon).addDisposableTo(disposeBag)
            }

        } else {
            icon.value = anIcon
            timeOfDay = .afternoon
        }
        setUpWeatherAssets(iconResult: IconResult(string: icon.value, timeOfDay: timeOfDay) ?? .sunnyDay)
    }

    private func setUpWeatherAssets(iconResult: IconResult) {
        switch iconResult {
        case .sunnyNight:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherNightSunnyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherNightSunny")
        case .cloudyDay:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherDayCloudyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherDayCloudy")
        case .cloudyNight:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherNightCloudyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherNightCloudy")
        case .raining:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherDayNightRainingHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherDayLightning")
        case .windyDay:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherDayWindyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherDayWindy")
        case .windyNight:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherNightWindyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherNightWindy")
        default:
            weatherHomeScreen.value = #imageLiteral(resourceName: "weatherDaySunnyHomeScreen")
            weatherAddOutfit.value = #imageLiteral(resourceName: "weatherDaySunny")
        }
    }

}
