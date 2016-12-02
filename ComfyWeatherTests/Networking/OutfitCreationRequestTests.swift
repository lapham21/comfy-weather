//
//  OutfitCreationRequestTests.swift
//  ComfyWeather
//
//  Created by Son Le on 10/25/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Genome
import RealmSwift
import CoreLocation
@testable import ComfyWeather

final class OutfitCreationRequestTests: XCTestCase {

    private static let backendHost = "comfy-weather-server-staging.herokuapp.com"

    private static let stubFailureResponse: OHHTTPStubsResponse = {
        let notConnectedError = NSError(domain: NSURLErrorDomain,
                                        code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                        userInfo: nil)
        return OHHTTPStubsResponse(error: notConnectedError)
    }()

    // MARK: - Set up & tear down

    override func setUp() {
        super.setUp()

        deleteRealmData()
        setupMockRealmData()
    }

    private func deleteRealmData() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }

    private func setupMockRealmData() {
        let testUserInfo: Node = [
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
        guard let user = try? User(node: testUserInfo) else { return }

        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.add(user)
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()

        super.tearDown()
    }

    // MARK: - Tests

    func testOutfitCreationShouldSucceed() {
        let creationExpectation = expectation(description: "Created outfit")

        let testLocation = CLLocation(latitude: 30.0, longitude: 40.0)
        let testCategory = ClothingCategory(icon: #imageLiteral(resourceName: "cap"), name: "Cap")
        let testArticle = ArticleOfClothing(description: "Fluffy", category: testCategory)
        let testArticleId = testArticle.id

        let nodeInfo: [String : Any] = [
            "outfit" : [
                "id" : "\(arc4random())",
                "updated_at" : "2016-10-13T20:10:37Z",
                "created_at" : "2016-10-13T20:10:37Z",
                "latitude" : testLocation.coordinate.latitude,
                "longitude" : testLocation.coordinate.longitude,
                "photo_url" : "https://real.or/fake.jpg",
                "notes" : "pretty comfy",
                "latest_rating" : "comfy",
                "is_public" : false,
                "weather" : [
                    "summary" : "Partly Cloudy",
                    "icon" : "partly-cloudy-day",
                    "precipProbability" : 0,
                    "temperature" : 69.16,
                    "apparentTemperature" : 69.16
                ]
            ]
        ]
        var node = Node(any: nodeInfo)
        node["outfit", "article_of_clothings"] = try? [testArticle].makeNode()

        let _ = stubOutfitCreationRequests(with: node)

        let request = OutfitCreationRequest(location: testLocation, articlesOfClothing: [testArticle])
        request?.create { result in
            switch result {
            case .success(let outfit):
                XCTAssert(outfit.articlesOfClothing.first?.id == testArticleId)
                creationExpectation.fulfill()

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testOutfitCreationShouldSucceedDespiteMissingOptionalData() {
        let creationExpectation = expectation(description: "Created outfit")

        let testLocation = CLLocation(latitude: 30.0, longitude: 40.0)
        let testCategory = ClothingCategory(icon: #imageLiteral(resourceName: "cap"), name: "Cap")
        let testArticle = ArticleOfClothing(description: "Fluffy", category: testCategory)
        let testArticleId = testArticle.id

        let nodeInfo: [String : Any] = [
            "outfit" : [
                "id" : "\(arc4random())",
                "updated_at" : "2016-10-13T20:10:37Z",
                "created_at" : "2016-10-13T20:10:37Z",
                "latitude" : testLocation.coordinate.latitude,
                "longitude" : testLocation.coordinate.longitude,
                "weather" : [
                    "summary" : "Partly Cloudy",
                    "icon" : "partly-cloudy-day",
                    "precipProbability" : 0,
                    "temperature" : 69.16,
                    "apparentTemperature" : 69.16
                ]
            ]
        ]
        var node = Node(any: nodeInfo)
        node["outfit", "article_of_clothings"] = try? [testArticle].makeNode()

        let _ = stubOutfitCreationRequests(with: node)

        let request = OutfitCreationRequest(location: testLocation, articlesOfClothing: [testArticle])
        request?.create { result in
            switch result {
            case .success(let outfit):
                XCTAssert(outfit.articlesOfClothing.first?.id == testArticleId)
                creationExpectation.fulfill()

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testOutfitCreationShouldFail() {
        let failureExpectation = expectation(description: "Should fail")

        let _ = stubBackendRequestsWithFailure()

        let testLocation = CLLocation(latitude: 30.0, longitude: 40.0)
        let request = OutfitCreationRequest(location: testLocation, articlesOfClothing: [])
        request?.create { result in
            switch result {
            case .success:
                XCTFail("Shouldn't have succeeded.")

            case .failure:
                failureExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Helpers

    private func stubOutfitCreationRequests(with node: Node) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(OutfitCreationRequestTests.backendHost)
                    && isPath("/outfits")
                    && isMethodPOST(),

            response: { _ in
                do {
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    XCTFail("Couldn't stub requests. This shouldn't happen...")
                    return OutfitCreationRequestTests.stubFailureResponse
                }
            }
        )
    }

    private func stubBackendRequestsWithFailure() -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(OutfitCreationRequestTests.backendHost)
                    && isPath("/outfits")
                    && isMethodPOST(),

            response: { _ in
                return OutfitCreationRequestTests.stubFailureResponse
            }
        )
    }

}
