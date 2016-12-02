//
//  LoginRequest.swift
//  ComfyWeather
//
//  Created by Son Le on 10/20/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RealmSwift
import Alamofire

struct LoginRequest {

    private var request: BackendRequest

    func authenticate(completion: ( (Result<User>) -> () )? = nil) {
        request.request { response in
            switch response.result {
            case .success(let jsonData):
                do {
                    let jsonNode = try jsonData.makeNode()
                    guard let userNode = jsonNode["user"] else {
                        completion?(.failure(BackendRequestError.general("Could not read JSON")))
                        return
                    }

                    let user = try User(node: userNode)

                    let realm = try Realm()
                    try realm.write {
                        realm.add(user, update: true)

                        let otherUsers = realm.objects(User.self).filter("id != '\(user.id)'")
                        realm.delete(otherUsers)
                    }

                    completion?(.success(user))
                }
                catch {
                    completion?(.failure(BackendRequestError.other(error)))
                }

            case .failure(let error):
                completion?(.failure(BackendRequestError.other(error)))
            }
        }
    }

    init(facebookToken: String) {
        request = BackendRequest()
        request.endpoint = "/users"
        request.method = .post
        request.parameters = ["access_token" : facebookToken]
        request.encoding = URLEncoding.queryString
    }

}
