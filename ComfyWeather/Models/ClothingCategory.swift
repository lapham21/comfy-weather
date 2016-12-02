//
//  ClothingCategory.swift
//  ComfyWeather
//
//  Created by Son Le on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome
import RealmSwift

typealias ClothingCategoryContext = [String : Int]

private let fields = (
    id : "id",
    updatedDate : "updated_at",
    creationDate : "created_at",
    name : "name"
)

final class ClothingCategory: RealmSwift.Object, MappableObject {

    private(set) dynamic var id = ""
    private(set) dynamic var updatedDate = Date()
    private(set) dynamic var creationDate = Date()
    private(set) dynamic var name = ""
    private(set) dynamic var iconUrlString: String?
    private      dynamic var iconScale = Int(UIScreen.main.scale)

    private var icon: UIImage?

    func getIcon() -> UIImage? {
        if let icon = icon {
            return icon
        }

        if let localIconUrl = URL.localCategoryIconUrl(categoryId: id) {
            setIcon(url: localIconUrl, writeToLocal: false)
        }

        return icon
    }

    static func with(id: String) -> ClothingCategory? {
        return (try? Realm())?.objects(ClothingCategory.self).filter("id = '\(id)'").first
    }

    // MARK: - Creating mock categories

    convenience init(icon: UIImage, name: String) {
        self.init()

        // This initializer is only used to create mock categories.
        id = "\(arc4random())"
        updatedDate = Date()
        creationDate = Date()
        iconUrlString = nil
        iconScale = Int(icon.scale)

        self.name = name
        self.icon = icon
    }

    // MARK: - RealmSwift.Object

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func indexedProperties() -> [String] {
        return ["name"]
    }

    // MARK: - Genome.MappableObject

    // Note that when initializing a new category from a node, we download its icon synchronously.
    // We therefore highly recommend calling this initializer from a background thread.
    convenience init(map: Map) throws {
        self.init()

        if let scale = (map.context as? ClothingCategoryContext)?["scale"] {
            iconScale = scale
        }

        id = try map.extract(fields.id)
        updatedDate = try map.extract(fields.updatedDate) {
            CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        creationDate = try map.extract(fields.creationDate) {
            CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        name = try map.extract(fields.name)

        do {
            iconUrlString = try map.extract("selected_icon_\(iconScale)x_url")
        }
        catch {
            iconUrlString = nil
        }

        if let iconUrlString = iconUrlString, let iconUrl = URL(string: iconUrlString)?.withSecureScheme() {
            setIcon(url: iconUrl, writeToLocal: true)
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
        try name ~> map[fields.name]
        try iconUrlString ~> map["selected_icon_\(iconScale)x_url"]
    }

    // MARK: - Equatable

    override public func isEqual(_ object: Any?) -> Bool {
        guard let otherCategory = object as? ClothingCategory else { return false }

        return id == otherCategory.id
    }

    // MARK: - Helpers

    private func setIcon(url: URL, writeToLocal: Bool) {
        guard
            let iconData = try? Data(contentsOf: url),
            let icon = UIImage(data: iconData, scale: CGFloat(iconScale))
            else {
                return
            }

        self.icon = icon

        if writeToLocal, let localIconUrl = URL.localCategoryIconUrl(categoryId: id) {
            try? iconData.write(to: localIconUrl)
        }
    }

}
