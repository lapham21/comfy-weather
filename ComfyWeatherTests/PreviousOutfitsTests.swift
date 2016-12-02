//
//  PreviousOutfitsTests.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/20/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import ComfyWeather

class PreviousOutfitsComfyWeatherTests: XCTestCase {
    
    func testPreviousOutfitModelParsingWorks() {
        let viewModel = PreviousOutfitsViewModel()
        
        fetchMockPreviousOutfits(with: viewModel) { result in
            XCTAssert(result > 0, "PreviousOutfits Model is still parsing the data")
        }
    }
    
    private func fetchMockPreviousOutfits(with viewModel: PreviousOutfitsViewModel, completion: (Int) -> ()) {
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: "MockPreviousOutfitsData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                let dataNode = try data.makeNode()
                
                guard let previousOutfitsNode = dataNode["outfits"] else { return }
                viewModel.previousOutfits = try [PreviousOutfit](node: previousOutfitsNode)
                completion(viewModel.previousOutfits.count)
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
