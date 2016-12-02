//
//  PreviousOutfitsRequest.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Alamofire
import CoreLocation

struct PreviousOutfitsRequest {
    
    private var request: BackendRequest
    
    func getPreviousOutfits(completion: @escaping (Result<[PreviousOutfit]>) -> ()) {
        request.request { response in
            switch response.result {
            case let .success(data):
                do {
                    let dataNode = try data.makeNode()
                    guard let previousOutfitsNode = dataNode["outfits"] else { return }
                    
                    let previousOutfits = try [PreviousOutfit](node: previousOutfitsNode)
                    completion(.success(previousOutfits))
                }
                catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, token: String) {
        request = BackendRequest()
        request.endpoint = "/outfits"
        request.method = .get
        request.headers = ["Authorization" : "Token token=\(token)"]
        request.parameters = [
            "latitude" : latitude,
            "longitude" : longitude
        ]
        request.encoding = URLEncoding.queryString
    }
}
