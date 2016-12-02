//
//  WeatherTypeViewModel.swift
//  ComfyWeather
//
//  Created by MIN BU on 9/30/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift

final class WeatherTypeViewModel {

    //MARK: Enums and Variables

    let weatherType: WeatherRating
    private var textColor = Variable<UIColor?>(UIColor.comfyLightDarkBlueColor)
    private(set) var textColorObservable: Observable<UIColor?>
    var weatherImage = Variable<UIImage?>(nil)
    private(set) var weatherImageForView: Observable<UIImage?>
    let weatherText: String
    var isSelected: Bool {
        didSet {
            comfortabilityButtonSelected()
            determineWeatherLabelColor()
        }
    }

    //Mark: Initalization

    init(weatherType type: WeatherRating) {
        weatherImageForView = weatherImage.asObservable()
        isSelected = false
        textColorObservable = textColor.asObservable()
        
        switch type {
        case .chilly:
            weatherText = "Chilly"
            weatherImage.value = #imageLiteral(resourceName: "comfortChilly")
            weatherType = .chilly
        case .comfy:
            weatherText = "Comfy"
            weatherImage.value = #imageLiteral(resourceName: "comfortComfy")
            weatherType = .comfy
        case .toasty:
            weatherText = "Toasty"
            weatherImage.value = #imageLiteral(resourceName: "comfortToasty")
            weatherType = .toasty
        }
    }

    //MARK: Utility Function

    func comfortabilityButtonSelected() {
        switch weatherType {
        case .chilly:
            if isSelected {
                weatherImage.value = #imageLiteral(resourceName: "comfortChillySelected")
            } else {
                weatherImage.value = #imageLiteral(resourceName: "comfortChilly")
            }
        case .comfy:
            if isSelected {
                weatherImage.value = #imageLiteral(resourceName: "comfortComfySelected")
            } else {
                weatherImage.value = #imageLiteral(resourceName: "comfortComfy")
            }
        case .toasty:
            if isSelected {
                weatherImage.value = #imageLiteral(resourceName: "comfortToastySelected")
            } else {
                weatherImage.value = #imageLiteral(resourceName: "comfortToasty")
            }
        }
    }
    
    func determineWeatherLabelColor() {
        if isSelected {
            textColor.value = UIColor.comfyDarkBlueColor
        } else {
            textColor.value = UIColor.comfyLightDarkBlueColor
        }

    }
}
