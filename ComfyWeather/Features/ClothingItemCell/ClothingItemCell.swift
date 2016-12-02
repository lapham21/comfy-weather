//
//  ClothingItemCell.swift
//  ComfyWeather
//
//  Created by Son Le on 10/6/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class ClothingItemCell: UICollectionViewCell {

    @IBOutlet weak var outfitIconView: UIImageView!
    @IBOutlet weak var outfitLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        outfitLabel.ip_setCharacterSpacing(value: 0.3)
    }

    func configure(with model: ClothingItemCellViewModel) {
        outfitIconView.image = model.icon
        outfitLabel.text = model.label
    }
}
