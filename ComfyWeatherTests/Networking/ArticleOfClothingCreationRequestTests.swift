//
//  ArticleOfClothingCreationRequestTests.swift
//  ComfyWeather
//
//  Created by Son Le on 10/24/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Genome
import RealmSwift
@testable import ComfyWeather

final class ArticleOfClothingCreationRequestTests: XCTestCase {

    private static let backendHost = "comfy-weather-server-staging.herokuapp.com"

    private static let stubFailureResponse: OHHTTPStubsResponse = {
        let notConnectedError = NSError(domain: NSURLErrorDomain,
                                        code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                        userInfo: nil)
        return OHHTTPStubsResponse(error: notConnectedError)
    }()

    private let testUserInfo: Node = [
        "user" : [
            "id" : "1-800-NOT-AN-ID",
            "updated_at" : "2016-03-24T09:00:01Z",
            "created_at" : "1994-03-24T08:59:43Z",
            "email" : "joanne@bornthisway.foundation",
            "gender" : "agender",
            "preferred_time" : "18:00:50",
            "weather_perception" : "toasty",
            "uid" : "UNIQUE-ENOUGH",
            "name" : "The Fame",
            "auth_token" : "TOTALLY-REAL-TOKEN",
            "auth_expires_at" : "2016-11-20T17:14:10Z",
            "avatar_url" : "https://buy-joanne-on.itunes/pls.png"
        ]
    ]

    // MARK: - Set up & tear down

    override func setUp() {
        super.setUp()

        deleteRealmData()
        stubAuthenticationRequests()
    }

    private func deleteRealmData() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }

    private func stubAuthenticationRequests() {
        let _ = stubAuthenticationBackendRequests(with: testUserInfo)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()

        super.tearDown()
    }

    // MARK: - Tests

    func testArticleOfClothingCreationShouldSucceed() {
        let creationExpectation = expectation(description: "Created article of clothing")

        let testDescription = "Santa Shirt"
        let testCategory = ClothingCategory(icon: #imageLiteral(resourceName: "polo"), name: "Santa Clothes")
        if let realm = try? Realm() {
            try? realm.write { realm.add(testCategory) }
        }
        let testCategoryId = testCategory.id

        let _ = stubArticleOfClothingCreationRequests(withDescription: testDescription, categoryId: testCategoryId)

        LoginRequest(facebookToken: "FAKE-TOKEN").authenticate { _ in
            guard let testCategory = ClothingCategory.with(id: testCategoryId) else {
                XCTFail("Could not retrieve fake category")
                return
            }

            let request = ArticleOfClothingCreationRequest(description: testDescription, category: testCategory)
            request?.create { result in
                switch result {
                case .success(let article):
                    XCTAssert(article.userDescription == testDescription)
                    XCTAssert(article.category?.id == testCategoryId)
                    XCTAssert(article.user?.id == User.current?.id)
                    
                    creationExpectation.fulfill()
                    
                case .failure(let error):
                    if let backendError = error as? BackendRequestError {
                        XCTFail(backendError.localizedDescription)
                    }
                    else {
                        XCTFail(error.localizedDescription)
                    }
                }
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testArticleOfClothingCreationShouldFail() {
        let failureExpectation = expectation(description: "Request failed")

        let testDescription = "c'est la vie"
        let testCategory = ClothingCategory(icon: #imageLiteral(resourceName: "polo"), name: "Nope")
        if let realm = try? Realm() {
            try? realm.write { realm.add(testCategory) }
        }
        let testCategoryId = testCategory.id

        let _ = stubBackendRequestsWithFailure()

        LoginRequest(facebookToken: "FAKE-TOKEN").authenticate { _ in
            guard let testCategory = ClothingCategory.with(id: testCategoryId) else {
                XCTFail("Could not retrieve fake category")
                return
            }
            let request = ArticleOfClothingCreationRequest(description: testDescription, category: testCategory)
            
            request?.create { result in
                switch result {
                case .success:
                    XCTFail("Request should have failed")
                    
                case .failure:
                    failureExpectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testArticleOfClothingCreationShouldFailNotLoggedIn() {
        let testDescription = "How Can Clothes Be Real If The User Isn't Real"
        let testCategory = ClothingCategory(icon: #imageLiteral(resourceName: "polo"), name: "Jaden")

        let request = ArticleOfClothingCreationRequest(description: testDescription, category: testCategory)
        XCTAssertNil(request)
    }

    // MARK: - Helpers

    private func stubArticleOfClothingCreationRequests(withDescription description: String,
                                                       categoryId: String) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(ArticleOfClothingCreationRequestTests.backendHost)
                    && isPath("/article_of_clothings")
                    && isMethodPOST(),

            response: { _ in
                do {
                    let node: Node = [
                        "article_of_clothing" : [
                            "id" : .string("\(arc4random())"),
                            "updated_at" : "2016-10-11T17:05:11Z",
                            "created_at" : "2016-10-11T17:05:11Z",
                            "description" : .string(description),
                            "frequency" : 0,
                            "category_name" : "Heels",
                            "category_id" : .string(categoryId)
                        ]
                    ]
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    return ArticleOfClothingCreationRequestTests.stubFailureResponse
                }
            }
        )
    }

    private func stubAuthenticationBackendRequests(with node: Node) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(ArticleOfClothingCreationRequestTests.backendHost)
                    && isPath("/users")
                    && isMethodPOST(),

            response: { _ in
                do {
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    return ArticleOfClothingCreationRequestTests.stubFailureResponse
                }
            }
        )
    }

    private func stubBackendRequestsWithFailure() -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(ArticleOfClothingCreationRequestTests.backendHost)
                    && isPath("/article_of_clothings")
                    && isMethodPOST(),

            response: { _ in
                return ArticleOfClothingCreationRequestTests.stubFailureResponse
            }
        )
    }

}
