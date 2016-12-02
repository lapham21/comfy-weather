//
//  CommonDateFormatters.swift
//  ComfyWeather
//
//  Created by Son Le on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

struct CommonDateFormatters {

    static let previousOutfitDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE - MMMM d, yyyy"
        return formatter
    }()

    static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private init() { }

}
