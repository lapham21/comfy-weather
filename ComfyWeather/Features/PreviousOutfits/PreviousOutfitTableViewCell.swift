//
//  PreviousOutfitTableViewCell.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class PreviousOutfitTableViewCell: UITableViewCell, UICollectionViewDataSource {

    //MARK: Variables

    var previousOutfitViewModel: PreviousOutfitViewModel?

    //MARK: IBOutlets

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var outfitImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var comfyImageView: UIImageView!
    @IBOutlet weak var clothingCollectionView: UICollectionView!
    @IBOutlet weak var noteLabel: UILabel!

    //MARK: TableView Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupClothingItemsView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupBorder()
    }

    //MARK: Configuration

    func configure(with previousOutfitViewModel: PreviousOutfitViewModel) {
        self.previousOutfitViewModel = previousOutfitViewModel

        weatherImageView.image = previousOutfitViewModel.getWeatherImage()
        temperatureLabel.text = previousOutfitViewModel.temperatureText
        outfitImageView.image = nil
        previousOutfitViewModel.getImage() { [weak self] image in
            self?.outfitImageView.image = image
        }
        dateLabel.text = previousOutfitViewModel.dateText
        previousOutfitViewModel.getReverseGeoCodeLocation() { [weak self] result in
            switch result {
            case .success(let geoLocation):
                self?.locationLabel.text = geoLocation
            case .failure(let error):
                print(error)
                self?.locationLabel.text = "Unknown Location"
            }
        }
        comfyImageView.image = previousOutfitViewModel.getComfyImage()
        noteLabel.text = previousOutfitViewModel.previousOutfit.notes
    }

    private func setupClothingItemsView() {
        clothingCollectionView.registerNib(of: ClothingItemCell.self)

        let insets = UIEdgeInsets(top: 0, left: 30.0, bottom: 0, right: 30.0)
        clothingCollectionView.scrollIndicatorInsets = insets
        clothingCollectionView.contentInset = insets

        clothingCollectionView.dataSource = self
    }

    private func setupBorder() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topRight, .topLeft], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        outfitImageView.layer.mask = maskLayer

        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.comfyCoolGreyColor.cgColor
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return previousOutfitViewModel?.outfitCollection.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let genericCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ClothingItemCell.self)",
            for: indexPath)
        guard
            let cell = genericCell as? ClothingItemCell,
            let previousOutfitViewModel = previousOutfitViewModel
            else { return genericCell }

        cell.configure(with: previousOutfitViewModel.clothingItemCellViewModel(for: indexPath))

        return cell
    }
}
