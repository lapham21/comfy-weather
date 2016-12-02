//
//  OutfitCreationRequest.swift
//  ComfyWeather
//
//  Created by Son Le on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Alamofire
import CoreLocation

struct OutfitCreationRequest {

    private let request: BackendRequest

    func create(completion: ( (Result<Outfit>) -> () )? = nil) {
        request.request { response in
            switch response.result {
            case .success(let jsonData):
                do {
                    let jsonNode = try jsonData.makeNode()
                    guard let outfitNode = jsonNode["outfit"] else {
                        completion?(.failure(BackendRequestError.general("Could not read JSON")))
                        return
                    }

                    let context = OutfitContext(userId: User.current?.id)
                    let outfit = try Outfit(node: outfitNode, in: context)

                    completion?(.success(outfit))
                }
                catch {
                    completion?(.failure(BackendRequestError.other(error)))
                }

            case .failure(let error):
                completion?(.failure(BackendRequestError.other(error)))
            }
        }
    }

    init?(location: CLLocation,
          articlesOfClothing: [ArticleOfClothing],
          photo: UIImage? = nil,
          notes: String? = nil,
          rating: WeatherRating? = nil,
          user: User? = nil) {
        guard let token = user?.token ?? User.current?.token else { return nil }

        var outfitsParameters = [
            "latitude" : "\(location.coordinate.latitude)",
            "longitude" : "\(location.coordinate.longitude)",
        ]
        if let notes = notes, notes.isEmpty == false {
            outfitsParameters["notes"] = notes
        }
        if let photo = photo, let photoData = UIImageJPEGRepresentation(photo, 0.7) {
            outfitsParameters["photo"] = "data:image/jpg;base64,\(photoData.base64EncodedString())"
        }
        var parameters: Parameters = [
            "outfit" : outfitsParameters,
            "article_of_clothings" : articlesOfClothing.map { $0.id }
        ]
        if let rating = rating {
            parameters["rating"] = rating.rawValue
        }

        request = BackendRequest(
            endpoint: "/outfits",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: ["Authorization" : "Token token=\(token)"]
        )
    }

}
