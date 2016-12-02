//
//  ClothingCategoryRequest.swift
//  ComfyWeather
//
//  Created by Son Le on 10/20/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RealmSwift
import Alamofire

struct ClothingCategoryRequest {

    private var request: BackendRequest

    func fetchCategories(scale: Int? = nil, completion: ( (Result<[ClothingCategory]>) -> () )? = nil) {
        request.request { response in
            switch response.result {
            case .success(let jsonData):
                do {
                    let jsonNode = try jsonData.makeNode()
                    guard let clothingCategoriesNode = jsonNode["categories"] else {
                        completion?(.failure(BackendRequestError.general("Could not read JSON")))
                        return
                    }

                    var context = ClothingCategoryContext()
                    if let scale = scale {
                        context["scale"] = scale
                    }

                    let unfilteredCategories = try [ClothingCategory](node: clothingCategoriesNode, in: context)
                    let categories = unfilteredCategories.filter { $0.getIcon() != nil }

                    let realm = try Realm()
                    try realm.write {
                        realm.add(categories, update: true)

                        let deletedClothingCategories = realm.objects(ClothingCategory.self).filter { category in
                            categories.contains(category) == false
                        }
                        realm.delete(deletedClothingCategories)
                    }

                    completion?(.success(categories))
                }
                catch {
                    completion?(.failure(BackendRequestError.other(error)))
                }

            case .failure(let error):
                completion?(.failure(BackendRequestError.other(error)))
            }
        }
    }

    init() {
        request = BackendRequest()
        request.endpoint = "/categories"
        request.method = .get
    }

}
