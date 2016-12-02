//
//  ArticleOfClothing.swift
//  ComfyWeather
//
//  Created by Son Le on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome
import RealmSwift

struct ArticleOfClothingContext: Context {
    var userId: String?
}

private let fields = (
    id : "id",
    updatedDate : "updated_at",
    creationDate : "created_at",
    description : "description",
    frequency : "frequency",
    categoryId : "category_id"
)

final class ArticleOfClothing: RealmSwift.Object, MappableObject {

    private(set) dynamic var id = ""
    private(set) dynamic var updatedDate = Date()
    private(set) dynamic var creationDate = Date()
    private(set) dynamic var userDescription = ""
    private(set) dynamic var frequency = 0
    private(set) dynamic var category: ClothingCategory?
    private(set) dynamic var user: User?

    // MARK: - Mocking articles of clothing

    convenience init(description aDescription: String, category aCategory: ClothingCategory) {
        self.init()

        id = "\(arc4random())"
        userDescription = aDescription
        category = aCategory
        user = User.current
    }

    // MARK: - RealmSwift.Object

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["frequency"]
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
        userDescription = try map.extract(fields.description)
        frequency = try map.extract(fields.frequency)

        let realm = try? Realm()

        category = try map.extract(fields.categoryId) { (categoryId: String) in
            realm?.objects(ClothingCategory.self)
                  .filter("id = '\(categoryId)'")
                  .first
        }

        if let userId = (map.context as? ArticleOfClothingContext)?.userId {
            user = realm?.objects(User.self)
                         .filter("id = '\(userId)'")
                         .first
        }
    }

    func sequence(_ map: Map) throws {
        try id ~> map[fields.id]
        try updatedDate ~> map[fields.updatedDate].transformToNode {
            CommonDateFormatters.isoDateFormatter.string(from: $0)
        }
        try creationDate ~> map[fields.creationDate].transformToNode {
            CommonDateFormatters.isoDateFormatter.string(from: $0)
        }
        try userDescription ~> map[fields.description]
        try frequency ~> map[fields.frequency]
        try category ~> map[fields.categoryId].transformToNode { $0?.id ?? "" }
    }

    // MARK: - Equatable

    override public func isEqual(_ object: Any?) -> Bool {
        return id == (object as? ArticleOfClothing)?.id
    }

}
