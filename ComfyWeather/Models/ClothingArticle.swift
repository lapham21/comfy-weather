//
//  ClothingArticle.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/19/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Genome

struct ClothingArticle {
    
    fileprivate static let fields = (
        id : "id",
        updated_at : "updated_at",
        created_at : "created_at",
        description : "description",
        frequency : "frequency",
        category_name : "category_name",
        category_id : "category_id"
    )
    
    let id: String?
    let updatedDate: Date
    let createdDate: Date
    let description: String?
    let frequency: Int
    let categoryName: String
    let categoryId: String
    
    fileprivate static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
}

extension ClothingArticle: MappableObject {
    
    init(map: Map) throws {
        id = try map.extract(ClothingArticle.fields.id)
        updatedDate = try map.extract(ClothingArticle.fields.updated_at) {
            return ClothingArticle.isoDateFormatter.date(from: $0) ?? Date()
        }
        createdDate = try map.extract(ClothingArticle.fields.created_at) {
            return ClothingArticle.isoDateFormatter.date(from: $0) ?? Date()
        }
        description = try map.extract(ClothingArticle.fields.description)
        frequency = try map.extract(ClothingArticle.fields.frequency)
        categoryName = try map.extract(ClothingArticle.fields.category_name)
        categoryId = try map.extract(ClothingArticle.fields.category_id)

    }
}
