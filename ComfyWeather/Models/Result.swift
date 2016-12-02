//
//  Result.swift
//  ComfyWeather
//
//  Created by Son Le on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
