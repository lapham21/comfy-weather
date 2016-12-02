//
//  ArticleOfClothingCreationRequest.swift
//  ComfyWeather
//
//  Created by Son Le on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Alamofire

struct ArticleOfClothingCreationRequest {

    private let request: BackendRequest

    func create(completion: ( (Result<ArticleOfClothing>) -> () )? = nil) {
        request.request { response in
            switch response.result {
            case .success(let jsonData):
                do {
                    let jsonNode = try jsonData.makeNode()
                    guard let articleNode = jsonNode["article_of_clothing"] else {
                        completion?(.failure(BackendRequestError.general("Could not read JSON")))
                        return
                    }

                    let context = ArticleOfClothingContext(userId: User.current?.id)
                    let article = try ArticleOfClothing(node: articleNode, in: context)

                    completion?(.success(article))
                }
                catch {
                    completion?(.failure(BackendRequestError.other(error)))
                }

            case .failure(let error):
                completion?(.failure(BackendRequestError.other(error)))
            }
        }
    }

    init?(description: String, category: ClothingCategory, user: User? = nil) {
        guard let token = user?.token ?? User.current?.token else { return nil }

        request = BackendRequest(
            endpoint: "/article_of_clothings",
            method: .post,
            parameters: [
                "article_of_clothing" : [
                    "description" : description,
                    "category_id" : category.id
                ]
            ],
            encoding: JSONEncoding.default,
            headers: ["Authorization" : "Token token=\(token)"]
        )
    }

}
