//
//  HomeScreenViewModel.swift
//  ComfyWeather
//
//  Created by Son Le on 10/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift

final class HomeScreenViewModel {

    struct RecommendedOutfit {
        var icon: UIImage
        var category: String
    }
    private let disposeBag = DisposeBag()

    var recommendedOutfits = Variable<[ClothingItemCellViewModel]>([])

    let location: Observable<String>

    var weatherAssetsViewModel = WeatherAssetsViewModel()

    // MARK: - Child view models

    var morningForecastViewModel = ForecastColumnViewModel()
    var afternoonForecastViewModel = ForecastColumnViewModel()
    var eveningForecastViewModel = ForecastColumnViewModel()

    init() {
        location = LocationService.sharedInstance.geoLocationObservable.map {
            if case .success(let location) = $0 {
                return location.uppercased()
            } else {
                return LocationService.sharedInstance.lastGeoCode?.uppercased() ?? ""
            }
        }
    }

    // MARK: - Fetching forecasts

    func requestForecasts() {
        morningForecastViewModel.period.value = "Morning"
        setupBindings(for: FetchWeatherService.sharedInstance.morningWeatherModelObservable, to: morningForecastViewModel)

        afternoonForecastViewModel.period.value = "Afternoon"
        setupBindings(for: FetchWeatherService.sharedInstance.afternoonWeatherModelObservable, to: afternoonForecastViewModel)

        eveningForecastViewModel.period.value = "Evening"
        setupBindings(for: FetchWeatherService.sharedInstance.eveningWeatherModelObservable, to: eveningForecastViewModel)
    }

    private func setupBindings(for weatherModel: Observable<Weather?>, to viewModel: ForecastColumnViewModel) {
        weatherModel.map { $0?.temperature }
            .bindTo(viewModel.temperature)
            .addDisposableTo(disposeBag)
        weatherModel.map { $0?.apparentTemperature }
            .bindTo(viewModel.apparentTemperature)
            .addDisposableTo(disposeBag)
        weatherModel.map { [weak self] in
            self?.convertWindBearingToDirection(withBearing: $0?.windBearing ?? 0)
            }
            .bindTo(viewModel.windDirection)
            .addDisposableTo(disposeBag)
        weatherModel.map { $0?.windSpeed }
            .bindTo(viewModel.windSpeed)
            .addDisposableTo(disposeBag)
        weatherModel.map { $0?.humidity }
            .bindTo(viewModel.humidity)
            .addDisposableTo(disposeBag)
    }

    private func convertWindBearingToDirection(withBearing bearing: Int) -> String {
        switch bearing {
        case 0..<45, 315...360: return "N"
        case 45..<135: return "E"
        case 135..<225: return "S"
        case 225..<314: return "W"
        default: return "N"
        }
    }

    func fetchRecommendedOutfits() {
        // TODO: Get recommended outfits from backend. Using dummy data for now.
        recommendedOutfits.value = [ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "coat"), label: "Coat"),
                                    ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "buttonDown"), label: "Flannel"),
                                    ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "pants"), label: "Jeans"),
                                    ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "boots"), label: "Boots")]
    }
}
