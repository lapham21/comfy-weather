//
//  AddClothingView.swift
//  ComfyWeather
//
//  Created by Son Le on 10/12/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class AddClothingView: UIView {

    @IBOutlet weak var categoriesView: UICollectionView!

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()

        categoriesView.registerNib(of: ClothingItemCell.self)
        categoriesView.registerNib(of: AddClothingInputView.self,
                                   forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
    }

}
