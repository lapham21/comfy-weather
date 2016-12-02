//
//  PreviousOutfitsViewModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift

final class PreviousOutfitsViewModel {

    // MARK: Variables

    var previousOutfits = [PreviousOutfit]()
    let disposeBag = DisposeBag()
    private let afternoonWeatherModel = Variable<Weather?>(nil)
    var cellType: UITableViewCell.Type {
        if previousOutfits.count == 0 {
            return NoPreviousOutfitsTableViewCell.self
        } else {
            return PreviousOutfitTableViewCell.self
        }
    }
    
    init() {
        FetchWeatherService.sharedInstance.afternoonWeatherModelObservable.bindTo(afternoonWeatherModel).addDisposableTo(disposeBag)
    }

    // MARK: Get Outfits

    func getPreviousOutfits(completion: @escaping () -> ()) {
        guard
            let location = LocationService.sharedInstance.lastLocation,
            let token = User.current?.token
        else { return }

        let previousOutfitsRequest = PreviousOutfitsRequest(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, token: token)
        previousOutfitsRequest.getPreviousOutfits { [weak self] result in
            switch result {
            case .success(let previousOutfits):
                self?.previousOutfits = previousOutfits
                completion()
            case .failure(let error):
                print(error)
                completion()
            }
        }
    }

    // MARK: Configure Previous Outfit View Models

    func previousOutfitViewModel(for indexPath: IndexPath) -> PreviousOutfitViewModel {
        return PreviousOutfitViewModel(with: previousOutfits[indexPath.section])
    }

    // MARK: Return String for temperature range

    func getTemperatureRange() -> String {
        guard let temp = afternoonWeatherModel.value?.temperature else { return "" }

        let bottomOfRange = Int(temp) - Int(temp) % 10
        
        return "\(bottomOfRange)-\(bottomOfRange+10)°"
    }
    
    func getWeatherSummary() -> String {
        guard let summary = afternoonWeatherModel.value?.summary else { return "" }
        return " \(summary.lowercased()) days"
    }
}
