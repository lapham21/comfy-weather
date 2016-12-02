//
//  UIFont+ComfyWeather.swift
//  ComfyWeather
//
//  Created by Son Le on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UIFont {

    enum ChivoFontStyle: String {
        case black = "Black"
        case blackItalic = "BlackItalic"
        case bold = "Bold"
        case boldItalic = "BoldItalic"
        case italic = "Italic"
        case light = "Light"
        case lightItalic = "LightItalic"
    }

    enum Slabo13pxFontStyle: String {
        case regular = "Regular"
    }

    class func chivo(size: CGFloat = 7.0, style: ChivoFontStyle = .bold) -> UIFont? {
        let fontName = "Chivo-\(style.rawValue)"
        return UIFont(name: fontName, size: size)
    }

    class func slabo13px(size: CGFloat = 6.5, style: Slabo13pxFontStyle = .regular) -> UIFont? {
        let fontName = "Slabo13px-\(style.rawValue)"
        return UIFont(name: fontName, size: size)
    }

}
