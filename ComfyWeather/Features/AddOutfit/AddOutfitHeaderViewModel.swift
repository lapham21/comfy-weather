//
//  AddOutfitHeaderViewModel.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift

final class AddOutfitHeaderViewModel {

    private(set) var tempLabelText: Observable<String?>
    var weatherImage = Variable<UIImage?>(nil)
    var weatherAssetsViewModel = WeatherAssetsViewModel()

    private var disposeBag = DisposeBag()

    init() {
        let weatherModel = FetchWeatherService.sharedInstance.afternoonWeatherModelObservable

        tempLabelText = weatherModel.map { model in
            guard let temperature = model?.temperature else { return nil }
            return "\(Int(temperature))°"}
    }

}


