//
//  Bundle+Load.swift
//  ComfyWeather
//
//  Created by Son Le on 10/7/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

extension Bundle {

    func load<T>(_ type: T.Type) -> T? {
        guard let nib = loadNibNamed("\(type)", owner: nil, options: nil) else { return nil }
        for object in nib {
            if let matchingObject = object as? T {
                return matchingObject
            }
        }
        return nil
    }

}
