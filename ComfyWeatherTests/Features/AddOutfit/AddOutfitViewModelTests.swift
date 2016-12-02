//
//  AddOutfitViewModelTests.swift
//  ComfyWeather
//
//  Created by Son Le on 10/16/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import OHHTTPStubs
import RealmSwift
import Genome
@testable import ComfyWeather

final class AddOutfitViewModelTests: XCTestCase {

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

        stubCategoryRequests()
        deleteRealmData()
        deleteCategoryIconsDirectory()
    }

    private func stubCategoryRequests() {
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

    func testInitialization() {
        let initExpectation = expectation(description: "Successfully initialized")

        ClothingCategoryRequest().fetchCategories { _ in
            let viewModel = AddOutfitViewModel()

            XCTAssert(viewModel.numberOfClothingItems == 1)

            let addClothingCellIndex = viewModel.numberOfClothingItems - 1

            XCTAssert(viewModel.cellModelForClothingItem(at: addClothingCellIndex)
                == ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "addClothing"), label: "Add Clothing"))

            XCTAssert(viewModel.numberOfCategorySections == 1)
            XCTAssert(viewModel.numberOfCategories(in: 0) == 2)

            XCTAssertNil(viewModel.selectedCategoryIndexPath)
            XCTAssertFalse(viewModel.isCategorySelected)

            XCTAssertNil(viewModel.selectedClothingItemIndex)
            XCTAssertFalse(viewModel.isClothingItemSelected)

            initExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testSelectingClothingItem() {
        let selectExpectation = expectation(description: "Selected clothing items")

        ClothingCategoryRequest().fetchCategories { _ in
            let viewModel = AddOutfitViewModel()

            viewModel.selectClothingItem(at: 1000)
            XCTAssertFalse(viewModel.isClothingItemSelected,
                           "Shouldn't be able to select a clothing item that doesn't exist.")

            let addClothingCellIndex = viewModel.numberOfClothingItems - 1

            // Select "Add Clothing" cell and verify cell is selected.
            XCTAssert(viewModel.canSelectClothingItem(at: addClothingCellIndex))
            viewModel.selectClothingItem(at: addClothingCellIndex)
            XCTAssert(viewModel.isClothingItemSelected)
            XCTAssert(viewModel.selectedClothingItemIndex == addClothingCellIndex)
            XCTAssert(viewModel.cellModelForClothingItem(at: addClothingCellIndex)
                == ClothingItemCellViewModel(icon: #imageLiteral(resourceName: "addClothingExit"), label: "Done"))
            (0 ..< viewModel.numberOfClothingItems).forEach { index in
                XCTAssert(viewModel.alphaForClothingItems(at: index) == (index == addClothingCellIndex ? 1.0 : 0.4))
            }

            // Select "Add Clothing" cell again and verify cell is deselected.
            viewModel.selectClothingItem(at: addClothingCellIndex)
            XCTAssertFalse(viewModel.isClothingItemSelected)
            XCTAssertNil(viewModel.selectedClothingItemIndex)
            (0 ..< viewModel.numberOfClothingItems).forEach { index in
                XCTAssert(viewModel.alphaForClothingItems(at: index) == 1.0)
            }

            selectExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testSelectingCategory() {
        let selectExpectation = expectation(description: "Selected categories")

        ClothingCategoryRequest().fetchCategories { _ in
            let viewModel = AddOutfitViewModel()
            
            viewModel.selectCategory(at: IndexPath(row: 0, section: 0))
            XCTAssertFalse(viewModel.isCategorySelected,
                           "Shouldn't be able to select a category if you haven't selected a clothing item.")
            
            let addClothingCellIndex = viewModel.numberOfClothingItems - 1
            viewModel.selectClothingItem(at: addClothingCellIndex)
            
            viewModel.selectCategory(at: IndexPath(row: 5, section: 0))
            XCTAssertFalse(viewModel.isCategorySelected, "Shouldn't be able to select non-existent category.")
            
            let selectedIndexPath = IndexPath(row: 0, section: 0)
            
            // Select category (0, 0) and verify it is selected.
            viewModel.selectCategory(at: selectedIndexPath)
            XCTAssert(viewModel.isCategorySelected)
            XCTAssert(viewModel.selectedCategoryIndexPath == selectedIndexPath)
            (0 ..< viewModel.numberOfCategorySections).forEach { section in
                (0 ..< viewModel.numberOfCategories(in: section)).forEach { row in
                    let indexPath = IndexPath(row: row, section: section)
                    XCTAssert(viewModel.alphaForCategory(at: indexPath) == (indexPath == selectedIndexPath ? 1.0 : 0.4))
                }
            }

            selectExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAddingClothingItem() {
        let additionExpectation = expectation(description: "Added clothing item")

        ClothingCategoryRequest().fetchCategories { _ in
            let viewModel = AddOutfitViewModel()

            let selectedClothingItemIndex = viewModel.numberOfClothingItems - 1
            let selectedCategoryIndexPath = IndexPath(row: 0, section: 0)

            viewModel.selectClothingItem(at: selectedClothingItemIndex)
            viewModel.selectCategory(at: selectedCategoryIndexPath)

            viewModel.finalizeClothingItemAddition()
            XCTAssert(viewModel.numberOfClothingItems == 1) // Shouldn't add new clothing item if user hasn't named it.

            let inputViewModel = viewModel.inputViewModelForCategory(at: selectedCategoryIndexPath)
            inputViewModel.outfitName.value = "Spiffy"

            viewModel.finalizeClothingItemAddition()
            XCTAssert(viewModel.numberOfClothingItems == 2)
            XCTAssert(viewModel.cellModelForClothingItem(at: 0).label == "Spiffy")

            additionExpectation.fulfill()
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Helpers

    private func stubClothingCategoriesRequests(with node: Node) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(AddOutfitViewModelTests.backendHost)
                    && isPath("/categories")
                    && isMethodGET(),

            response: { _ in
                do {
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    return AddOutfitViewModelTests.stubFailureResponse
                }
            }
        )
    }

}
