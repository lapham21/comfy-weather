//
//  ForecastColumnViewModel.swift
//  ComfyWeather
//
//  Created by Son Le on 10/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift

final class ForecastColumnViewModel {

    // MARK: - Forecast data

    var period = Variable("Morning")
    var temperature = Variable<Double?>(99.0)
    var apparentTemperature = Variable<Double?>(99.0)
    var windSpeed = Variable<Double?>(4.0)
    var windDirection = Variable<String?>("N")
    var humidity = Variable<Double?>(0.91)

    // MARK: - Labels

    private(set) var periodLabelText: Observable<String?>
    private(set) var temperatureLabelText: Observable<String?>
    private(set) var metadataLabelText: Observable<String?>

    init() {
        periodLabelText = period.asObservable().map { $0.uppercased() }

        temperatureLabelText = temperature.asObservable().map {
            "\(Int($0 ?? 99.0))°"
        }

        metadataLabelText = Observable.combineLatest(
            apparentTemperature.asObservable(),
            windDirection.asObservable(),
            windSpeed.asObservable(),
            humidity.asObservable(),
            resultSelector: {
                guard let apparentTemp = $0,
                        let windDirection = $1,
                        let windSpeed = $2,
                        let humidity = $3
                else { return "" }
                return "Feels like \(Int(apparentTemp))°\n"
                    + "Wind: \(windDirection) \(windSpeed.rounded(to: 1))mph\n"
                    + "Humidity: \(Int(humidity * 100))%\n"
            }
        )
    }

}
