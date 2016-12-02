//
//  WeatherHomeScreenView.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift

final class WeatherHomeScreenView: UIView {

    @IBOutlet weak var weatherHomeScreenImage: UIImageView!
    private var disposeBag = DisposeBag()

    func configure(with model: WeatherAssetsViewModel) {
        model.weatherHomeScreen.asObservable().bindTo(weatherHomeScreenImage.rx.image).addDisposableTo(disposeBag)
    }

}
