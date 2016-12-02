//
//  PreviousOutfit.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome

enum WeatherRating: String {
    case chilly
    case comfy
    case toasty
}

struct PreviousOutfit {

    fileprivate static let fields = (
        id : "id",
        updated_at : "updated_at",
        created_at : "created_at",
        latitude : "latitude",
        longitude : "longitude",
        notes : "notes",
        is_public : "is_public",
        photo_url : "photo_url",
        latest_rating : "latest_rating",
        weather : "weather",
        article_of_clothings : "article_of_clothings"
    )

    let id: String?
    let updatedDate: Date
    let createdDate: Date
    let latitude: Double
    let longitude: Double
    let notes: String?
    let isPublic: Bool?
    let photoURL: URL?  //Should I turn this to a UIImage?????
    var latestRating = WeatherRating.comfy
    let weather: Weather?
    var articlesOfClothings = [ClothingArticle]()
    
    fileprivate static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
}

extension PreviousOutfit: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract(PreviousOutfit.fields.id)
        updatedDate = try map.extract(PreviousOutfit.fields.updated_at) {
            return PreviousOutfit.isoDateFormatter.date(from: $0) ?? Date()
        }
        createdDate = try map.extract(PreviousOutfit.fields.created_at) {
            return PreviousOutfit.isoDateFormatter.date(from: $0) ?? Date()
        }
        latitude = try map.extract(PreviousOutfit.fields.latitude)
        longitude = try map.extract(PreviousOutfit.fields.longitude)
        notes = try map.extract(PreviousOutfit.fields.notes)
        isPublic = try map.extract(PreviousOutfit.fields.is_public)
        photoURL = try map.extract(PreviousOutfit.fields.photo_url) { (node: Node) -> URL? in
            switch node {
            case let .string(value):
                return URL(string: value)?.withSecureScheme()
            case .null:
                return nil
            default:
                throw NodeError.unableToConvert(node: node, expected: "\((URL?).self)")
            }
        }
        latestRating = WeatherRating.comfy
        let weatherNode: Node = try map.extract(PreviousOutfit.fields.weather)
        weather = try Weather(node: weatherNode)
        let clothingNode: Node = try map.extract(PreviousOutfit.fields.article_of_clothings)
        articlesOfClothings = try [ClothingArticle](node: clothingNode)
    }
}
