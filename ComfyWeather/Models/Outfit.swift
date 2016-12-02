//
//  Outfit.swift
//  ComfyWeather
//
//  Created by Son Le on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome
import RealmSwift

struct OutfitContext: Context {
    let userId: String?
}

private let fields = (
    id : "id",
    updatedDate : "updated_at",
    creationDate : "created_at",
    latitude : "latitude",
    longitude : "longitude",
    notes : "notes",
    isPublic : "is_public",
    photoUrl : "photo_url",
    latestRating : "latest_rating",
    weather : "weather",
    articlesOfClothing : "article_of_clothings"
)

final class Outfit: RealmSwift.Object, MappableObject {

    private(set) dynamic var id = ""
    private(set) dynamic var updatedDate = Date()
    private(set) dynamic var creationDate = Date()
    private(set) dynamic var latitude = 0.0
    private(set) dynamic var longitude = 0.0
    private(set) dynamic var notes: String?
                         let isPublic = RealmOptional<Bool>()
    private      dynamic var photoUrlString: String?
    private      dynamic var latestRatingString: String?
    private(set)         var weather: Weather?
                         let articlesOfClothing = List<ArticleOfClothing>()
    private(set) dynamic var user: User?

    var photoUrl: URL? {
        guard let photoUrlString = photoUrlString else { return nil }
        return URL(string: photoUrlString)?.withSecureScheme()
    }

    var latestRating: WeatherRating? {
        guard let latestRatingString = latestRatingString else { return nil }
        return WeatherRating(rawValue: latestRatingString)
    }

    // MARK: - Mocking outfits

    convenience init(latitude aLatitude: Double,
                     longitude aLongitude: Double,
                     notes someNotes: String? = nil,
                     articlesOfClothing someArticles: [ArticleOfClothing]? = nil) {
        self.init()

        id = "\(arc4random())"
        latitude = aLatitude
        longitude = aLongitude
        notes = someNotes
        if let someArticles = someArticles {
            articlesOfClothing.append(objectsIn: someArticles)
        }
    }

    // MARK: - RealmSwift.Object

    override static func primaryKey() -> String {
        return "id"
    }

    // MARK: - Genome.MappableObject

    convenience init(map: Map) throws {
        self.init()

        id = try map.extract(fields.id)
        updatedDate = try map.extract(fields.updatedDate) {
            CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        creationDate = try map.extract(fields.creationDate) {
            CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        latitude = try map.extract(fields.latitude)
        longitude = try map.extract(fields.longitude)
        notes = try map.extract(fields.notes)
        isPublic.value = try map.extract(fields.isPublic)
        photoUrlString = try map.extract(fields.photoUrl)
        latestRatingString = try map.extract(fields.latestRating)
        weather = try map.extract(fields.weather)

        let maybeArticlesOfClothingArray: [ArticleOfClothing]? = try map.extract(fields.articlesOfClothing)
        if let articlesOfClothingArray = maybeArticlesOfClothingArray {
            articlesOfClothing.append(objectsIn: articlesOfClothingArray)
        }

        if let userId = (map.context as? OutfitContext)?.userId {
            let realm = try? Realm()
            user = realm?.objects(User.self).filter("id = '\(userId)'").first
        }
    }

    // MARK: - Equatable

    override public func isEqual(_ object: Any?) -> Bool {
        return id == (object as? Outfit)?.id
    }

}
