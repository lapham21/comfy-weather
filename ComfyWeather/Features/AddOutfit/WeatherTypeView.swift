//
//  WeatherTypeView.swift
//  ComfyWeather
//
//  Created by MIN BU on 9/30/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift

final class WeatherTypeView: UIView {

    //MARK: Variables and IBOutlets

    private var disposeBag = DisposeBag()
    var viewModel: WeatherTypeViewModel? = nil {
        didSet {
            configure(with: viewModel)
        }
    }

    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var comfyImage: UIImageView!

    //MARK: Configuration Utility Function

    private func configure(with: WeatherTypeViewModel?) {
        if let viewModel = viewModel {
            weatherLabel.text = viewModel.weatherText
            viewModel.textColorObservable.subscribe(onNext: { [weak self] in
                guard let welf = self else { return }
                welf.weatherLabel.textColor = $0
            }).addDisposableTo(disposeBag)
            viewModel.weatherImageForView.bindTo(comfyImage.rx.image).addDisposableTo(disposeBag)
            weatherLabel.ip_setCharacterSpacing(value: 0.3)
        }
    }
}
