//
//  User.swift
//  ComfyWeather
//
//  Created by Son Le on 9/28/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome
import RealmSwift

enum WeatherPerception: String {
    case toasty
    case neutral
    case chilly
}

private let fields = (
    id : "id",
    updatedDate : "updated_at",
    creationDate : "created_at",
    email : "email",
    gender : "gender",
    preferredTimeForNotifications : "preferred_time",
    weatherPerception : "weather_perception",
    uid : "uid",
    name : "name",
    token : "auth_token",
    tokenExpirationDate : "auth_expires_at",
    avatarUrl : "avatar_url"
)

final class User: RealmSwift.Object, MappableObject {

    private(set) dynamic var id = ""
    private(set) dynamic var updatedDate = Date()
    private(set) dynamic var creationDate = Date()
                 dynamic var email: String? = nil
                 dynamic var gender: String? = nil
                 dynamic var preferredTimeForNotifications: Date?
    private(set) dynamic var uid = ""
    private(set) dynamic var name = ""
    private(set) dynamic var token = ""
    private(set) dynamic var tokenExpirationDate = Date()
    private(set) dynamic var avatarUrlString: String? = nil
    private      dynamic var weatherPerceptionString = ""

    var weatherPerception: WeatherPerception {
        get {
            return WeatherPerception(rawValue: weatherPerceptionString) ?? .neutral
        }
        set {
            weatherPerceptionString = newValue.rawValue
        }
    }

    private var avatar: UIImage?

    func getAvatar() -> UIImage? {
        if let avatar = avatar {
            return avatar
        }

        if let localAvatarUrl = URL.localAvatarIconUrl(userId: id) {
            setAvatar(url: localAvatarUrl, writeToLocal: false)
        }

        return avatar
    }

    static var current: User? {
        return (try? Realm())?.objects(User.self).first
    }

    // MARK: - RealmSwift.Object

    override static func primaryKey() -> String {
        return "id"
    }

    // MARK: - Genome.MappableObject

    convenience init(map: Map) throws {
        self.init()

        // I put throw statements in some of these transformers to conform to Genome and Node's convention of throwing a
        // NodeError if they are unable to convert a Node to a different type.

        id = try map.extract(fields.id)
        updatedDate = try map.extract(fields.updatedDate) {
            return CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        creationDate = try map.extract(fields.creationDate) {
            return CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        email = try map.extract(fields.email)
        gender = try map.extract(fields.gender)
        preferredTimeForNotifications = try map.extract(fields.preferredTimeForNotifications) { (node: Node) -> Date? in
            switch node {
            case let .string(value):
                return CommonDateFormatters.timeFormatter.date(from: value)
            case .null:
                return nil
            default:
                throw NodeError.unableToConvert(node: node, expected: "\((Date?).self)")
            }
        }
        weatherPerception = try map.extract(fields.weatherPerception) {
            WeatherPerception(rawValue: $0) ?? .neutral
        }
        uid = try map.extract(fields.uid)
        name = try map.extract(fields.name)
        token = try map.extract(fields.token)
        tokenExpirationDate = try map.extract(fields.tokenExpirationDate) {
            return CommonDateFormatters.isoDateFormatter.date(from: $0) ?? Date()
        }
        avatarUrlString = try map.extract(fields.avatarUrl)

        if let avatarUrlString = avatarUrlString, let avatarUrl = URL(string: avatarUrlString)?.withSecureScheme() {
            setAvatar(url: avatarUrl, writeToLocal: true)
        }
    }

    func sequence(_ map: Map) throws {
        try id ~> map[fields.id]
        try updatedDate ~> map[fields.updatedDate].transformToNode { CommonDateFormatters.isoDateFormatter.string(from: $0) }
        try creationDate ~> map[fields.creationDate].transformToNode { CommonDateFormatters.isoDateFormatter.string(from: $0) }
        try email ~> map[fields.email]
        try gender ~> map[fields.gender]
        try preferredTimeForNotifications ~> map[fields.preferredTimeForNotifications].transformToNode { time -> Node in
            if let time = time {
                return Node(CommonDateFormatters.timeFormatter.string(from: time))
            }
            else {
                return .null
            }
        }
        try weatherPerception ~> map[fields.weatherPerception].transformToNode { $0.rawValue }
        try uid ~> map[fields.uid]
        try name ~> map[fields.name]
        try token ~> map[fields.token]
        try tokenExpirationDate ~> map[fields.tokenExpirationDate].transformToNode {
            CommonDateFormatters.isoDateFormatter.string(from: $0)
        }
        try avatarUrlString ~> map[fields.avatarUrl]
    }

    // MARK: - Equatable

    override public func isEqual(_ object: Any?) -> Bool {
        guard let otherUser = object as? User else { return false }
        return id == otherUser.id
    }

    // MARK: - Helpers

    private func setAvatar(url: URL, writeToLocal: Bool) {
        guard
            let avatarData = try? Data(contentsOf: url),
            let avatar = UIImage(data: avatarData)
            else {
                return
            }

        self.avatar = avatar

        if writeToLocal, let localAvatarUrl = URL.localAvatarIconUrl(userId: id) {
            try? avatarData.write(to: localAvatarUrl)
        }
    }

}
