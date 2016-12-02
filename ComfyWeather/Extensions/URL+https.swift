//
//  URL+https.swift
//  ComfyWeather
//
//  Created by Son Le on 10/21/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

extension URL {

    func withSecureScheme() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        return components?.url
    }

}
