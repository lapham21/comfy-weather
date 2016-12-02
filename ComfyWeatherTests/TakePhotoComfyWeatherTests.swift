//
//  TakePhotoComfyWeatherTests.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 9/30/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import AVFoundation
import XCTest
@testable import ComfyWeather

class TakePhotoComfyWeatherTests: XCTestCase {

    func testCurrentOutfitNilUponInit() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()

        XCTAssert(outfitPhotoViewModel.outfitImage.value == nil, "Photo is initialized with a value")
    }

    func testSettingCurrentOutfitWithNotSetupStillImageOutputFrontCamera() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()
        let stillImageOutput = AVCaptureStillImageOutput()

        let expectationForTest = expectation(description: "")

        outfitPhotoViewModel.setOutfitImage(with: stillImageOutput) { result in
            switch result {
            case .success(_):
                XCTAssert(false, "Successfully made an image when it should have failed")
            case .failure(let error):
                XCTAssert(true, "Failure to make a photo from outfitViewModel with error: \(error)")
                expectationForTest.fulfill()
            }
        }

        waitForExpectations(timeout: 10)
    }

    #if !(arch(i386) || arch(x86_64))
        func testSettingCurrentOutfitWithFrontCamera() {
            let outfitPhotoViewModel = OutfitPhotoViewModel()
            let stillImageOutput = setInputandOutputForACCaptureSession(with: true)

            let expectationForTest = expectation(description: "")

            outfitPhotoViewModel.setOutfitImage(with: stillImageOutput) { result in
                switch result {
                case .success(_):
                    XCTAssert(true, "Successfully made an image from Back Camera")
                    expectationForTest.fulfill()
                case .failure(let error):
                    XCTAssert(false, "Failure to make a photo from outfitViewModel with error: \(error)")
                }
            }

            waitForExpectations(timeout: 10)
        }

        func testSettingCurrentOutfitWithBackCamera() {
            let outfitPhotoViewModel = OutfitPhotoViewModel()
            let stillImageOutput = setInputandOutputForACCaptureSession(with: false)
            let expectationForTest = expectation(description: "")

            outfitPhotoViewModel.setOutfitImage(with: stillImageOutput) { result in
                switch result {
                case .success(_):
                    XCTAssert(true, "Successfully made an image from Back Camera")
                    expectationForTest.fulfill()
                case .failure(let error):
                    XCTAssert(false, "Failure to make a photo from outfitViewModel with error: \(error)")
                }
            }
            waitForExpectations(timeout: 10)
        }
    #else
        func testSettingCurrentOutfitWithFrontCameraAndBackCameraOnSimulator() {
            XCTAssert(true, "Cannot test the camera on a simulator. Please run tests on a device.")
        }
    #endif

    private func setInputandOutputForACCaptureSession(with isFrontCamera: Bool) -> AVCaptureStillImageOutput {
        
        let backCamera = camera(withPosition: .back)
        let frontCamera = camera(withPosition: .front)
        var stillImageOutput: AVCaptureStillImageOutput?
        var previewLayer: AVCaptureVideoPreviewLayer?
        let device: AVCaptureDevice?

        if isFrontCamera {
            device = frontCamera
        } else {
            device = backCamera
        }

        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error {
            print(error)
            input = nil
        }

        captureSession.addInput(input)

        stillImageOutput = AVCaptureStillImageOutput()
        guard let stillImageOutputUnwrapped = stillImageOutput else { return AVCaptureStillImageOutput() }
        stillImageOutputUnwrapped.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        captureSession.startRunning()

        return stillImageOutputUnwrapped

    }

    private func camera(withPosition position: AVCaptureDevicePosition) -> AVCaptureDevice {
        if let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            if let device = videoDevices.filter({ $0.position == position }).first {
                return device
            }
        }
        return AVCaptureDevice()
    }

    func testClearCurrentOutfitImage() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()

        outfitPhotoViewModel.outfitImage.value = #imageLiteral(resourceName: "exitMenuWhite")

        outfitPhotoViewModel.clearCurrentOufitImage()

        XCTAssertNil(outfitPhotoViewModel.outfitImage.value, "Image not cleared")
        XCTAssert(true, "Image Cleared successfully")
    }

    func testFetchPhotoLibrary() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()
        weak var expectationForTest = expectation(description: "")

        outfitPhotoViewModel.getPhotoLibrary {
            if outfitPhotoViewModel.getPhotoCount() != 0 {
                XCTAssert(true, "Successfully fetched the photo gallery")
                expectationForTest?.fulfill()
                expectationForTest = nil
                return
            } else if outfitPhotoViewModel.getPhotoCount() == 0 {
                XCTAssert(false, "Un-successfully fetched the photo gallery")
            }
        }
        waitForExpectations(timeout: 10)
    }

    #if !(arch(i386) || arch(x86_64))
        func testGetPhotoForSavedPhotoViewController() {
            let outfitPhotoViewModel = OutfitPhotoViewModel()
            let stillImageOutput = setInputandOutputForACCaptureSession(with: false)
            let expectationForTest = expectation(description: "")
            
            outfitPhotoViewModel.setOutfitImage(with: stillImageOutput) { result in
                switch result {
                case .success(_):
                    if let _ = outfitPhotoViewModel.getPhotoForSavedPhotoViewController() {
                        XCTAssert(true, "Successfully made an image from Back Camera, and got it using the function in question")
                        expectationForTest.fulfill()
                    }
                case .failure(let error):
                    XCTAssert(false, "Failure to make a photo from outfitViewModel with error: \(error)")
                }
            }
            waitForExpectations(timeout: 10)
        }
    #else
    func testGetPhotoForSavedPhotoViewControllerSimulator() {
        XCTAssert(true, "Cannot test the camera on a simulator. Please run tests on a device.")
    }
    #endif

    func testGetPhoto() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()
        weak var expectationForTest = expectation(description: "")
        var image: UIImage?
        
        outfitPhotoViewModel.getPhotoLibrary {
            image = outfitPhotoViewModel.getPhoto(for: IndexPath(row: 0, section: 1))
            if image != nil {
                XCTAssert(true, "Successfully fetched the photo")
                expectationForTest?.fulfill()
                expectationForTest = nil
            } else if image == nil {
                XCTAssert(false, "Un-successfully fetched the photo")
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testSetPhoto() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()
        weak var expectationForTest = expectation(description: "")

        outfitPhotoViewModel.getPhotoLibrary {
            outfitPhotoViewModel.setPhoto(for: IndexPath(row: 0, section: 1)) { image in
                if let _ = outfitPhotoViewModel.outfitImage.value {
                    XCTAssert(true, "Successfully set the outfitImage")
                    expectationForTest?.fulfill()
                    expectationForTest = nil
                } else if outfitPhotoViewModel.outfitImage.value == nil {
                    XCTAssert(false, "Un-successfully set the outfitImage")
                }
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetPhotoCount() {
        let outfitPhotoViewModel = OutfitPhotoViewModel()
        weak var expectationForTest = expectation(description: "")
        var count = 0
        
        outfitPhotoViewModel.getPhotoLibrary {
            count += 1
            if outfitPhotoViewModel.getPhotoCount() == count {
                XCTAssert(true, "getPhotoCount function working")
                expectationForTest?.fulfill()
                expectationForTest = nil
            } else if outfitPhotoViewModel.getPhotoCount() != count {
                XCTAssert(false, "getPhotoCount function not working")
            }
        }
        waitForExpectations(timeout: 10)
    }
}
