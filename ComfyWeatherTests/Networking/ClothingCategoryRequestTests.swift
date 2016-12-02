//
//  ClothingCategoryRequestTests.swift
//  ComfyWeather
//
//  Created by Son Le on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Genome
import RealmSwift
@testable import ComfyWeather

final class ClothingCategoryRequestTests: XCTestCase {

    private static let backendHost = "comfy-weather-server-staging.herokuapp.com"

    private static let stubFailureResponse: OHHTTPStubsResponse = {
        let notConnectedError = NSError(domain: NSURLErrorDomain,
                                        code: Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue),
                                        userInfo: nil)
        return OHHTTPStubsResponse(error: notConnectedError)
    }()

    // MARK: - Set up

    override func setUp() {
        super.setUp()

        deleteRealmData()
        deleteCategoryIconsDirectory()
    }

    private func deleteRealmData() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }

    private func deleteCategoryIconsDirectory() {
        let fileManager = FileManager()

        let documentUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentUrl = documentUrls.first else { return }
        let categoriesUrl = documentUrl.appendingPathComponent("categories", isDirectory: true)

        try? fileManager.removeItem(at: categoriesUrl)
    }

    // MARK: - Tests

    func testFetchingClothingCategoriesWithNoErrors() {
        let testClothingCategoriesInfo: Node = [
            "categories" : [
                [
                    "id" : "ec2233da-f8ec-459c-a00b-ce8ba9b7c7b2",
                    "updated_at" : "2016-10-14T16:03:59Z",
                    "created_at" : "2016-10-14T16:02:16Z",
                    "name" : "Hat",
                    "selected_icon_1x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_1xes/ec2/233/da-/original/hat.png?1476461039",
                    "selected_icon_2x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_2xes/ec2/233/da-/original/hat.png?1476461039",
                    "selected_icon_3x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_3xes/ec2/233/da-/original/hat.png?1476461039"
                ],
                [
                    "id" : "379e4f6b-4f99-4c46-ae1b-57ed1dfc8e41",
                    "updated_at" : "2016-10-14T16:04:02Z",
                    "created_at" : "2016-10-14T16:02:17Z",
                    "name" : "Heels",
                    "selected_icon_1x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_1xes/379/e4f/6b-/original/heels.png?1476461042",
                    "selected_icon_2x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_2xes/379/e4f/6b-/original/heels.png?1476461042",
                    "selected_icon_3x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_3xes/379/e4f/6b-/original/heels.png?1476461042"
                ]
            ]
        ]

        let _ = stubClothingCategoriesRequests(with: testClothingCategoriesInfo)

        let fetchExpectation = expectation(description: "Successful fetch")
        let persistenceExpecation = expectation(description: "Successful persistence")

        let clothingCategoryRequest = ClothingCategoryRequest()
        clothingCategoryRequest.fetchCategories(scale: 2) { result in
            switch result {
            case .success(let clothingCategories):
                guard let expectedClothingCategoriesNode = testClothingCategoriesInfo["categories"] else {
                    XCTFail("Well this shouldn't happen…")
                    return
                }
                
                do {
                    let expectedClothingCategories = try [ClothingCategory](node: expectedClothingCategoriesNode,
                                                                            in: ["scale" : 2])
                    XCTAssertEqual(expectedClothingCategories, clothingCategories)
                    fetchExpectation.fulfill()
                    
                    let realm = try Realm()
                    let persistedCategories = realm.objects(ClothingCategory.self)
                    for category in clothingCategories {
                        if persistedCategories.index(of: category) == nil {
                            XCTFail("Category \(category) was not stored.")
                        }
                    }
                    persistenceExpecation.fulfill()
                }
                catch {
                    XCTFail(error.localizedDescription)
                }

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testFetchingClothingCategoriesWrongScale() {
        let testClothingCategoriesInfo: Node = [
            "categories" : [
                [
                    "id" : "ec2233da-f8ec-459c-a00b-ce8ba9b7c7b2",
                    "updated_at" : "2016-10-14T16:03:59Z",
                    "created_at" : "2016-10-14T16:02:16Z",
                    "name" : "Hat",
                    "selected_icon_1x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_1xes/ec2/233/da-/original/hat.png?1476461039",
                ],
                [
                    "id" : "379e4f6b-4f99-4c46-ae1b-57ed1dfc8e41",
                    "updated_at" : "2016-10-14T16:04:02Z",
                    "created_at" : "2016-10-14T16:02:17Z",
                    "name" : "Heels",
                    "selected_icon_1x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_1xes/379/e4f/6b-/original/heels.png?1476461042",
                    "selected_icon_2x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_2xes/379/e4f/6b-/original/heels.png?1476461042",
                    "selected_icon_3x_url" : "https://s3.amazonaws.com/comfy-weather-server-dev/categories/selected_icon_3xes/379/e4f/6b-/original/heels.png?1476461042"
                ]
            ]
        ]

        let _ = stubClothingCategoriesRequests(with: testClothingCategoriesInfo)

        let fetchExpection = expectation(description: "Fetch should succeed with only 1 result")

        let clothingCategoryRequest = ClothingCategoryRequest()
        clothingCategoryRequest.fetchCategories(scale: 2) { result in
            switch result {
            case .success(let clothingCategories):
                XCTAssert(clothingCategories.count == 1)
                fetchExpection.fulfill()

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testFetchingClothingCategoriesWithWrongIconUrl() {
        let testClothingCategoriesInfo: Node = [
            "categories" : [
                [
                    "id" : "ec2233da-f8ec-459c-a00b-ce8ba9b7c7b2",
                    "updated_at" : "2016-10-14T16:03:59Z",
                    "created_at" : "2016-10-14T16:02:16Z",
                    "name" : "Hat",
                    "selected_icon_2x_url" : "https://thisurlhadbetternotexistorelseisw.ear/"
                ],
            ]
        ]

        let _ = stubClothingCategoriesRequests(with: testClothingCategoriesInfo)

        let failureExpectation = expectation(description: "Fetch should succeed but return empty array")

        let clothingCategoryRequest = ClothingCategoryRequest()
        clothingCategoryRequest.fetchCategories(scale: 2) { result in
            switch result {
            case .success(let clothingCategories):
                XCTAssert(clothingCategories.isEmpty == true)
                failureExpectation.fulfill()

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testFetchingClothingCategoriesShouldFail() {
        let _ = stubBackendRequestsWithFailure()

        let failureExpectation = expectation(description: "Fetch should fail")

        let clothingCategoryRequest = ClothingCategoryRequest()
        clothingCategoryRequest.fetchCategories { result in
            switch result {
            case .success:
                XCTFail("Fetch should fail")
            case .failure:
                failureExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    private func stubClothingCategoriesRequests(with node: Node) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(ClothingCategoryRequestTests.backendHost)
                    && isPath("/categories")
                    && isMethodGET(),

            response: { _ in
                do {
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    return ClothingCategoryRequestTests.stubFailureResponse
                }
            }
        )
    }

    private func stubBackendRequestsWithFailure() -> OHHTTPStubsDescriptor {
        return stub(condition: isScheme("https") && isHost(ClothingCategoryRequestTests.backendHost)) { _ in
            return ClothingCategoryRequestTests.stubFailureResponse
        }
    }

}
