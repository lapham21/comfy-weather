//
//  TakePhotoViewController.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 9/27/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import AVFoundation

final class TakePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Global Variables and Outlets

    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isFrontCameraBeingUsed = false
    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    var viewModel: OutfitPhotoViewModel?
    private let savePhotoViewController = SavePhotoViewController()

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var previewView: UIView!
  
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {

        guard let stillImageOutput = stillImageOutput else { return }

        viewModel?.isFrontCameraBeingUsed = self.isFrontCameraBeingUsed
        self.viewModel?.setOutfitImage(with: stillImageOutput) { [weak self] result in
            guard let welf = self else { return }
            switch result {
            case .success(let viewModel):
                welf.viewModel?.isFrontCameraBeingUsed = welf.isFrontCameraBeingUsed
                welf.savePhotoViewController.viewModel = viewModel
                welf.navigationController?.pushViewController(welf.savePhotoViewController, animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func switchCameraButtonPressed(_ sender: UIButton) {

        var camera: AVCaptureDevice?
        if isFrontCameraBeingUsed {
            camera = backCamera
            isFrontCameraBeingUsed = !isFrontCameraBeingUsed
        } else {
            camera = frontCamera
            isFrontCameraBeingUsed = !isFrontCameraBeingUsed
        }
        captureSession?.stopRunning()
        setInputandOutputForACCaptureSession(camera)
    }

    @IBAction func flashButtonPressed(_ sender: UIButton) {
        toggleFlash()
    }

    private func toggleFlash() {
        // TODO: - update for retina front flash
        guard !isFrontCameraBeingUsed,
            let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo),
            device.hasFlash
            else { return }
        do {
            let _ = try device.lockForConfiguration()
        } catch let error {
            print(error)
            return
        }

        if device.isFlashActive {
            device.flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "photoFlashOff"), for: .normal)
        } else {
            device.flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "photoFlashOn"), for: .normal)
        }
        device.unlockForConfiguration()
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "TAKE PHOTO"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        checkAuthorizationStatus()

        backCamera = camera(withPosition: .back)
        frontCamera = camera(withPosition: .front)

        setInputandOutputForACCaptureSession(backCamera)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        previewLayer?.frame = previewView.bounds

    }

    // MARK: - ACCaptureSession Utility Functions

    private func setInputandOutputForACCaptureSession(_ device: AVCaptureDevice?) {

        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto

        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error {
            print(error)
            input = nil
        }

        if let _ = captureSession?.canAddInput(input) {
            captureSession?.addInput(input)

            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if let _ = captureSession?.canAddOutput(stillImageOutput) {
                captureSession?.addOutput(stillImageOutput)

                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                guard let previewLayer = previewLayer else { return }
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView?.layer.addSublayer(previewLayer)

                captureSession?.startRunning()
            }
        }
        previewLayer?.frame = previewView.bounds
    }

    func camera(withPosition position: AVCaptureDevicePosition) -> AVCaptureDevice {
        if let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] {
            if let device = videoDevices.filter({ $0.position == position }).first {
                return device
            }
        }
        return AVCaptureDevice()
    }

    func checkAuthorizationStatus() {
        // TODO: - If access not granted for camera, show how to request
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .denied:
            presentDeniedAccessModal()
        default: break
        }
    }

    func presentDeniedAccessModal() {
        let modalViewController = DeniedCameraPermissionsViewController()
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.currentContext
        self.navigationController?.pushViewController(modalViewController, animated: true)
    }
}
