//
//  PreviousOutfitViewModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import CoreLocation
import RealmSwift

final class PreviousOutfitViewModel {

    var previousOutfit: PreviousOutfit
    var outfitCollection = [ClothingArticle]()
    private var categories: Results<ClothingCategory>?
    var temperatureText: String {
        return "\(Int(previousOutfit.weather?.temperature ?? 99.0))°"
    }
    var dateText: String {
        return CommonDateFormatters.previousOutfitDateFormatter.string(from: previousOutfit.createdDate)
    }

    init(with previousOutfit: PreviousOutfit) {
        self.previousOutfit = previousOutfit
        if let realm = try? Realm() {
            categories = realm.objects(ClothingCategory.self)
        }
        outfitCollection = previousOutfit.articlesOfClothings
    }

    // MARK: Functions to return data for the tableview cells

    func getReverseGeoCodeLocation(completion: @escaping (Result<String?>) -> ()) {
        let location = CLLocation(latitude: previousOutfit.latitude, longitude: previousOutfit.longitude)
        LocationService.sharedInstance.reverseGeoCode(for: location) { result in
            switch result {
            case .success(let geoLocation):
                completion(.success(geoLocation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getWeatherImage() -> UIImage {
        let icon = previousOutfit.weather?.icon
        let weatherAssetsViewModel = WeatherAssetsViewModel(icon: icon)
        return weatherAssetsViewModel.weatherAddOutfit.value ?? #imageLiteral(resourceName: "weatherDaySunny")
    }

    private func getCategoryImage(with categoryID: String) -> UIImage? {
        guard let category = categories?.filter("id == '\(categoryID)'").first else { return nil }
        return category.getIcon()
    }

    func getImage(completion: @escaping (UIImage?) -> ()) {
        BackendRequest.getImage(from: previousOutfit.photoURL) { image in
            completion(image)
        }
    }

    func getComfyImage() -> UIImage {
        switch previousOutfit.latestRating {
        case .chilly:
            return #imageLiteral(resourceName: "comfortChillySelected")
        case .comfy:
            return #imageLiteral(resourceName: "comfortComfySelected")
        case .toasty:
            return #imageLiteral(resourceName: "comfortToastySelected")
        }
    }

    // MARK: Configure Model for clothing item views
    
    func clothingItemCellViewModel(for indexPath: IndexPath) -> ClothingItemCellViewModel {
        let icon = getCategoryImage(with: outfitCollection[indexPath.row].categoryId)
        return ClothingItemCellViewModel(icon: icon, label: outfitCollection[indexPath.row].categoryName)
    }
}
