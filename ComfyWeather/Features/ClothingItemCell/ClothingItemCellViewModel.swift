//
//  ClothingItemCellViewModel.swift
//  ComfyWeather
//
//  Created by Son Le on 10/11/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

struct ClothingItemCellViewModel {

    var icon: UIImage?
    var label: String?

}

extension ClothingItemCellViewModel: Equatable {

    static func ==(lhs: ClothingItemCellViewModel, rhs: ClothingItemCellViewModel) -> Bool {
        return lhs.icon == rhs.icon && lhs.label == rhs.label
    }

}
