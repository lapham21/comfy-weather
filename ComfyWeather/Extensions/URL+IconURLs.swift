//
//  URL+IconURLs.swift
//  ComfyWeather
//
//  Created by Son Le on 10/20/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

extension URL {

    static func localCategoryIconUrl(categoryId id: String) -> URL? {
        let fileManager = FileManager()

        let documentUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentUrl = documentUrls.first else { return nil }

        let categoriesUrl = documentUrl.appendingPathComponent("categories", isDirectory: true)

        guard let _ = try? fileManager.createDirectory(at: categoriesUrl, withIntermediateDirectories: true) else {
            return nil
        }

        let escapedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return categoriesUrl.appendingPathComponent("\(escapedId)", isDirectory: false)
    }

    static func localAvatarIconUrl(userId id: String) -> URL? {
        let fileManager = FileManager()

        let documentUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentUrl = documentUrls.first else { return nil }

        let usersUrl = documentUrl.appendingPathComponent("users", isDirectory: true)

        guard let _ = try? fileManager.createDirectory(at: usersUrl, withIntermediateDirectories: true) else {
            return nil
        }

        let escapedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        return usersUrl.appendingPathComponent("\(escapedId)", isDirectory: false)
    }

}
