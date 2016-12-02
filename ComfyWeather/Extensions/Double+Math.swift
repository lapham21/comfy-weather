//
//  Double+Math.swift
//  ComfyWeather
//
//  Created by Son Le on 10/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

extension Double {

    func rounded(to places: Int) -> Double {
        return rounded(to: places, rule: .toNearestOrAwayFromZero)
    }

    func rounded(to places: Int, rule: FloatingPointRoundingRule) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(rule) / divisor
    }

}
