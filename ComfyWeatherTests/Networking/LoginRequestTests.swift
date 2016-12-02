//
//  LoginRequestTests.swift
//  ComfyWeather
//
//  Created by Son Le on 9/30/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
import OHHTTPStubs
import RealmSwift
import Genome
@testable import ComfyWeather

final class LoginRequestTests: XCTestCase {

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
    }

    private func deleteRealmData() {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            realm.deleteAll()
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    // MARK: - Tests

    func testAuthenticationRequestShouldSucceed() {
        let testUserInfo: Node = [
            "user" : [
                "id" : "1-800-NOT-AN-ID",
                "updated_at" : "2016-03-24T09:00:01Z",
                "created_at" : "1994-03-24T08:59:43Z",
                "email" : "gallavich@shamele.ss",
                "gender" : "fluid",
                "preferred_time" : "18:00:50",
                "weather_perception" : "toasty",
                "uid" : "UNIQUE-ENOUGH",
                "name" : "Lito x Hernando",
                "auth_token" : "TOTALLY-REAL-TOKEN",
                "auth_expires_at" : "2016-11-20T17:14:10Z",
                "avatar_url" : "https://sens.e8/will.lito.jpg"
            ]
        ]

        testAuthenticationRequest(with: testUserInfo)
    }

    func testAuthenticationRequestShouldSucceedDespiteMissingOptionalData() {
        let testUserInfo: Node = [
            "user" : [
                "id" : "1-800-NOT-AN-ID",
                "updated_at" : "2016-03-24T09:00:01Z",
                "created_at" : "1994-03-24T08:59:43Z",
                "email" : nil,
                "gender" : nil,
                "preferred_time" : nil,
                "weather_perception" : "toasty",
                "uid" : "UNIQUE-ENOUGH",
                "name" : "Lito x Hernando",
                "auth_token" : "TOTALLY-REAL-TOKEN",
                "auth_expires_at" : "2016-11-20T17:14:10Z",
                "avatar_url" : nil
            ]
        ]

        testAuthenticationRequest(with: testUserInfo)
    }

    func testMultipleAuthenticationRequestsShouldSucceed() {
        let firstTestUserInfo: Node = [
            "user" : [
                "id" : "ahhhhhhhh",
                "updated_at" : "2016-03-24T09:00:01Z",
                "created_at" : "1994-03-24T08:59:43Z",
                "email" : nil,
                "gender" : nil,
                "preferred_time" : nil,
                "weather_perception" : "toasty",
                "uid" : "UNIQUE-ENOUGH",
                "name" : "Lito x Hernando",
                "auth_token" : "TOTALLY-REAL-TOKEN",
                "auth_expires_at" : "2016-11-20T17:14:10Z",
                "avatar_url" : nil
            ]
        ]

        testAuthenticationRequest(with: firstTestUserInfo)

        let secondTestUserInfo: Node = [
            "user" : [
                "id" : "ooooooohhhhhh",
                "updated_at" : "2016-03-24T09:00:01Z",
                "created_at" : "1994-03-24T08:59:43Z",
                "email" : nil,
                "gender" : nil,
                "preferred_time" : nil,
                "weather_perception" : "toasty",
                "uid" : "UNIQUE-ENOUGH",
                "name" : "Lito x Hernando",
                "auth_token" : "TOTALLY-REAL-TOKEN",
                "auth_expires_at" : "2016-11-20T17:14:10Z",
                "avatar_url" : nil
            ]
        ]

        testAuthenticationRequest(with: secondTestUserInfo)

        XCTAssert((try? Realm())?.objects(User.self).count == 1)
    }

    func testAuthenticationRequestShouldFailWhenGettingMalformedReply() {
        // Missing "updated_at", "created_at", "auth_token", and "auth_expires_at".
        let testUserInfo: Node = [
            "user" : [
                "id" : "1-800-NOT-AN-ID",
                "email" : nil,
                "gender" : nil,
                "preferred_time" : nil,
                "weather_perception" : "toasty",
                "uid" : "UNIQUE-ENOUGH",
                "name" : "Lito x Hernando",
                "avatar_url" : nil
            ]
        ]

        let failureExpectation = expectation(description: "Malformed reply")
        let _ = stubAuthenticationBackendRequests(with: testUserInfo)

        let request = LoginRequest(facebookToken: "1-800-NOT-REAL")
        request.authenticate { result in
            switch result {
            case .success:
                XCTFail("User model created despite malformed reply.")
            case .failure:
                failureExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    func testAuthenticationRequestShouldFail() {
        let failureExpectation = expectation(description: "Failed request")
        let _ = stubBackendRequestsWithFailure()

        let request = LoginRequest(facebookToken: "1-800-NOT-REAL")
        request.authenticate { result in
            switch result {
            case .success:
                XCTFail("This request should not have succeeded.")
            case .failure:
                failureExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    private func testAuthenticationRequest(with testUserInfo: Node) {
        let authExpectation = expectation(description: "Successful user authentication")
        let _ = stubAuthenticationBackendRequests(with: testUserInfo)

        let request = LoginRequest(facebookToken: "1-800-NOT-REAL")
        request.authenticate { result in
            switch result {
            case .success(let user):
                guard let testUser = try? User(node: testUserInfo["user"]) else {
                    XCTFail("Could not create test user.")
                    return
                }
                XCTAssertEqual(user, testUser)

                guard let currentUser = User.current else {
                    XCTFail("Could not get current user.")
                    return
                }
                XCTAssertEqual(user, currentUser)

                authExpectation.fulfill()

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Helpers

    private func stubAuthenticationBackendRequests(with node: Node) -> OHHTTPStubsDescriptor {
        return stub(
            condition: isScheme("https")
                    && isHost(LoginRequestTests.backendHost)
                    && isPath("/users")
                    && isMethodPOST(),

            response: { _ in
                do {
                    let data = try Data(node: node)
                    let headers = ["Content-Type" : "application/json; charset=utf-8"]

                    return OHHTTPStubsResponse(data: data, statusCode: 200, headers: headers)
                }
                catch {
                    return LoginRequestTests.stubFailureResponse
                }
            }
        )
    }

    private func stubBackendRequestsWithFailure() -> OHHTTPStubsDescriptor {
        return stub(condition: isScheme("https") && isHost(LoginRequestTests.backendHost)) { _ in
            return LoginRequestTests.stubFailureResponse
        }
    }

}
