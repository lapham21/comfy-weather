//
//  ForecastColumnView.swift
//  ComfyWeather
//
//  Created by Son Le on 10/4/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxCocoa
import RxSwift

final class ForecastColumnView: UIView {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var metadataLabel: UILabel!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

        periodLabel.ip_setCharacterSpacing(value: 0.5)
    }

    func configure(with model: ForecastColumnViewModel) {
        // Dispose of previous bindings.
        disposeBag = DisposeBag()

        model.periodLabelText.bindTo(periodLabel.rx.text).addDisposableTo(disposeBag)
        model.temperatureLabelText.bindTo(temperatureLabel.rx.text).addDisposableTo(disposeBag)
        model.metadataLabelText.bindTo(metadataLabel.rx.text).addDisposableTo(disposeBag)
    }

}
