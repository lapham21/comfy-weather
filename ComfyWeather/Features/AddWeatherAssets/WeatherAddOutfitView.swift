//
//  WeatherAddOutfitView.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift

final class WeatherAddOutfitView: UIView {

    @IBOutlet weak var weatherAddOutfitImage: UIImageView!

    private var disposeBag = DisposeBag()

    func configure(with model: WeatherAssetsViewModel) {
        model.weatherAddOutfit.asObservable().bindTo(weatherAddOutfitImage.rx.image).addDisposableTo(disposeBag)
    }

}
