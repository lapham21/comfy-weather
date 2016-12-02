//
//  UIView+Subview.swift
//  ComfyWeather
//
//  Created by Son Le on 10/4/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UIView {

    func fill(with subview: UIView) {
        subview.frame = bounds
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(subview)
    }

}
