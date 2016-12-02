//
//  CGRect+Math.swift
//  ComfyWeather
//
//  Created by Son Le on 10/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import CoreGraphics

extension CGRect {

    init(centeredIn rect: CGRect, width: CGFloat, height: CGFloat) {
        self.init()

        size.width = width
        size.height = height

        origin.x = rect.origin.x + (rect.size.width - width) / 2.0
        origin.y = rect.origin.y + (rect.size.height - height) / 2.0
    }

}
