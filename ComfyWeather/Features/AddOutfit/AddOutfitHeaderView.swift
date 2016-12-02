//
//  AddOutfitHeaderView.swift
//  ComfyWeather
//
//  Created by MIN BU on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxCocoa
import RxSwift

final class AddOutfitHeaderView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!

    private var disposeBag = DisposeBag()

    private let weatherAddOutfitView = Bundle.main.load(WeatherAddOutfitView.self)

    override func awakeFromNib() {
        super.awakeFromNib()

        addPhotoLabel.ip_setCharacterSpacing(value: 0.5)
    }

    func configure(with model: AddOutfitHeaderViewModel) {
        weatherAddOutfitView?.configure(with: model.weatherAssetsViewModel)
        guard let weatherAddOutfitView = weatherAddOutfitView else {return}
        weatherImageView.fill(with: weatherAddOutfitView)

        model.tempLabelText.bindTo(tempLabel.rx.text).addDisposableTo(disposeBag)

    }

}
