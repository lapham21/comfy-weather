//
//  WeatherModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/13/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome

struct Weather {

    fileprivate static let fields = (
        time : "time",
        summary : "summary",
        icon : "icon",
        precipIntensity : "precipIntensity",
        precipProbability : "precipProbability",
        precipType : "precipType",
        temperature : "temperature",
        apparentTemperature : "apparentTemperature",
        dewPoint : "dewPoint",
        humidity : "humidity",
        windSpeed : "windSpeed",
        windBearing : "windBearing",
        visibility : "visibility",
        cloudCover : "cloudCover",
        pressure : "pressure",
        ozone : "ozone"
    )

    let time: Int?
    let summary: String?
    let icon: String?
    let precipIntensity: Double?
    let precipProbability: Double
    let precipType: String?
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double?
    let humidity: Double?
    let windSpeed: Double?
    let windBearing: Int?
    let visibility: Double?
    let cloudCover: Double?
    let pressure: Double?
    let ozone: Double?
}

extension Weather: MappableObject {

    init(map: Map) throws {
        time = try map.extract(Weather.fields.time)
        summary = try map.extract(Weather.fields.summary)
        icon = try map.extract(Weather.fields.icon)
        precipIntensity = try map.extract(Weather.fields.precipIntensity)
        precipProbability = try map.extract(Weather.fields.precipProbability)
        precipType = try map.extract(Weather.fields.precipType)
        temperature = try map.extract(Weather.fields.temperature)
        apparentTemperature = try map.extract(Weather.fields.apparentTemperature)
        dewPoint = try map.extract(Weather.fields.dewPoint)
        humidity = try map.extract(Weather.fields.humidity)
        windSpeed = try map.extract(Weather.fields.windSpeed)
        windBearing = try map.extract(Weather.fields.windBearing)
        visibility = try map.extract(Weather.fields.visibility)
        cloudCover = try map.extract(Weather.fields.cloudCover)
        pressure = try map.extract(Weather.fields.pressure)
        ozone = try map.extract(Weather.fields.ozone)
    }
}
