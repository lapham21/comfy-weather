//
//  FetchWeatherViewModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/13/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import CoreLocation
import RxSwift

final class FetchWeatherService {

    static let sharedInstance: FetchWeatherService = {
        return FetchWeatherService()
    }()

    private var morningWeatherModel = Variable<Weather?>(nil)
    private var afternoonWeatherModel = Variable<Weather?>(nil)
    private var eveningWeatherModel = Variable<Weather?>(nil)

    private(set) var morningWeatherModelObservable: Observable<Weather?>
    private(set) var afternoonWeatherModelObservable: Observable<Weather?>
    private(set) var eveningWeatherModelObservable: Observable<Weather?>

    init() {
        morningWeatherModelObservable = morningWeatherModel.asObservable().observeOn(MainScheduler.instance)
        afternoonWeatherModelObservable = afternoonWeatherModel.asObservable().observeOn(MainScheduler.instance)
        eveningWeatherModelObservable = eveningWeatherModel.asObservable().observeOn(MainScheduler.instance)
    }

    func requestForecasts() {

        fetchWeather(with: .morning) { [weak self] result in
            switch result {
            case .success(let model):
                self?.morningWeatherModel.value = model
            case .failure(let error):
                print(error)
            }
        }

        fetchWeather(with: .afternoon) { [weak self] result in
            guard let welf = self else { return }
            switch result {
            case .success(let model):
                welf.afternoonWeatherModel.value = model
            case .failure(let error):
                print(error)
            }
        }

        fetchWeather(with: .evening) { [weak self] result in
            guard let welf = self else { return }
            switch result {
            case .success(let model):
                welf.eveningWeatherModel.value = model
            case .failure(let error):
                print(error)
            }
        }
    }

    private func fetchWeather(with period: BackendRequest.WeatherPeriod, completion: @escaping (Result<Weather>) -> ()) {

        guard let location = LocationService.sharedInstance.lastLocation else { return }

        let weatherRequest = BackendRequest.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, period: period)

        weatherRequest.request { response in
            switch response.result {
            case let .success(data):
                do {
                    let dataNode = try data.makeNode()
                    let weatherNode = dataNode["\(period)"]
                    let weatherModel = try Weather(node: weatherNode)
                    completion(.success(weatherModel))
                }
                catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
