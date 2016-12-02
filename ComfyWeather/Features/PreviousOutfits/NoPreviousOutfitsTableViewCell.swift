//
//  NoPreviousOutfitsTableViewCell.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class NoPreviousOutfitsTableViewCell: UITableViewCell {

    // MARK: IBOutlets

    @IBOutlet weak var noPreviousOutfitsLabel: UILabel!

    // MARK: Setup Helper Function

    func configure(with viewModel: PreviousOutfitsViewModel) {
        noPreviousOutfitsLabel.text = "You have not logged any comfy outfits for \(viewModel.getTemperatureRange())\(viewModel.getWeatherSummary())."
    }
}
