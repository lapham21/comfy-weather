//
//  BackendRequest.swift
//  ComfyWeather
//
//  Created by Son Le on 9/28/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Alamofire
import AlamofireImage

enum BackendRequestError: Error {
    case general(String)
    case other(Error)

    var localizedDescription: String {
        switch self {
        case .general(let message):
            return message
        case .other(let error):
            return error.localizedDescription
        }
    }
}

struct BackendRequest {

    enum WeatherPeriod: String {
        case morning
        case afternoon
        case evening
        case daily
    }

    private let backendHost = "https://comfy-weather-server-staging.herokuapp.com"

    private let defaultHeaders: HTTPHeaders = [
        "Accept" : "application/vnd.comfy-weather-server.com; version=1",
        "Content-Type" : "application/json"
    ]

    var endpoint = "/"
    var method = HTTPMethod.get
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil

    func request(queue: DispatchQueue = DispatchQueue.global(qos: .utility),
                 completionHandler: @escaping (DataResponse<Data>) -> Void) {
        let url = backendHost + endpoint

        // Join headers & defaultHeaders. If headers & defaultHeaders both contain values for an identical field, we
        // choose the one in headers over the one in defaultHeaders.
        var combinedHeaders = headers ?? [:]
        for (field, value) in defaultHeaders {
            if combinedHeaders[field] == nil {
                combinedHeaders[field] = value
            }
        }

        Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: combinedHeaders)
            .validate(statusCode: 200...299)
            .validate(contentType: ["application/json"])
            .responseData(queue: queue, completionHandler: completionHandler)
    }

    // MARK: - Pre-made requests

    static func fetchWeather(latitude: Double, longitude: Double, period: WeatherPeriod) -> BackendRequest {
        var request = BackendRequest()
        request.endpoint = "/forecasts"
        request.method = .post
        request.parameters = [
            "latitude" : latitude,
            "longitude" : longitude,
            "period" : period.rawValue
        ]
        request.encoding = URLEncoding.queryString

        return request
    }

    static func getImage(from url: URL?, completion: @escaping (Image?) -> ()) {
        guard let url = url else { return }

        Alamofire.request(url).responseImage { response in
            completion(response.result.value)
        }
    }
}
