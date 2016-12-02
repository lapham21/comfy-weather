//
//  FontTests.swift
//  ComfyWeather
//
//  Created by Son Le on 9/28/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import ComfyWeather

class FontTests: XCTestCase {

    func testChivoFontsExist() {
        XCTAssertNotNil(UIFont.chivo())
        XCTAssertNotNil(UIFont.chivo(size: 10.0, style: .black))
        XCTAssertNotNil(UIFont.chivo(size: 11.0, style: .blackItalic))
        XCTAssertNotNil(UIFont.chivo(size: 9.0, style: .bold))
        XCTAssertNotNil(UIFont.chivo(size: 9.5, style: .boldItalic))
        XCTAssertNotNil(UIFont.chivo(size: 19.0, style: .italic))
        XCTAssertNotNil(UIFont.chivo(size: 2.0, style: .light))
        XCTAssertNotNil(UIFont.chivo(size: 30.0, style: .lightItalic))
    }

    func testSlabo13pxFontsExist() {
        XCTAssertNotNil(UIFont.slabo13px())
        XCTAssertNotNil(UIFont.slabo13px(size: 10.0, style: .regular))
    }
    
}
