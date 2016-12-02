//
//  OutfitPhotoViewModel.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 9/28/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RxSwift

final class OutfitPhotoViewModel {

    var outfitImage = Variable<UIImage?>(nil)
    private var photoLibraryImages = [UIImage]()
    private var photoAssets: PHFetchResult<PHAsset>?
    var isFrontCameraBeingUsed = false

    enum PhotoError: String, Error {
        case photoIsNil = "Could not convert sampleBuffer to UIImage"
        case videoConnectionIsNil = "Could not create a videoConnection from stillImageOutput"
    }

    func setOutfitImage(with stillImageOutput: AVCaptureStillImageOutput, completion: @escaping (Result<OutfitPhotoViewModel>) -> ()) {

        guard let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
            else {
            completion(.failure(PhotoError.videoConnectionIsNil))
            return
        }

        videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
        stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { sampleBuffer, error in
            if let sampleBufferImage = sampleBuffer,
                error == nil {
                self.clearCurrentOufitImage()
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBufferImage) as CFData
                guard
                    let dataProvider = CGDataProvider(data: imageData),
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    else { return }

                if self.isFrontCameraBeingUsed {
                    self.outfitImage.value = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .leftMirrored)
                } else {
                    self.outfitImage.value = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: .right)
                }
                if self.outfitImage.value == nil {
                    completion(.failure(PhotoError.photoIsNil))
                    return
                }
                completion(.success(self))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }

    func clearCurrentOufitImage() {
        outfitImage.value = nil
    }

    func getPhotoLibrary(completion: @escaping () -> ()) {
        photoLibraryImages.removeAll()
        photoAssets = nil

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                      subtype: .smartAlbumUserLibrary,
                                                                      options: nil)
            collections.enumerateObjects({ [weak self] collection, start, stop in
                let assetFetchOptions = PHFetchOptions()
                assetFetchOptions.fetchLimit = 51
                assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                let assets = PHAsset.fetchAssets(in: collection, options: assetFetchOptions)
                self?.photoAssets = assets

                assets.enumerateObjects({ [weak self] asset, count, stop in
                    guard let welf = self else { return }

                    let image = welf.getAssetThumbnail(asset: asset)
                    welf.photoLibraryImages.append(image)
                    completion()
                    })
                })
        }
    }

    private func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        options.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
            guard let unwrappedThumbnail = result else { return }
            thumbnail = unwrappedThumbnail
        })
        return thumbnail
    }

    func getPhotoForSavedPhotoViewController() -> UIImage? {
        var image = outfitImage.value
        if isFrontCameraBeingUsed {
            guard let cgImage = image?.cgImage,
                let scale = image?.scale
                else { return image }
            image = UIImage(cgImage: cgImage, scale: scale, orientation: .rightMirrored)
        }
        return image
    }

    func getPhoto(for indexPath: IndexPath) -> UIImage {
        return photoLibraryImages[indexPath.row]
    }

    func setPhoto(for indexPath: IndexPath, completion: @escaping (UIImage?) -> ()) {
        guard
            let photoAssets = photoAssets,
            0 ..< photoAssets.count ~= indexPath.row
            else { return }
        let asset = photoAssets[indexPath.row]

        let manager = PHImageManager.default()

        let options = PHImageRequestOptions()
        options.resizeMode = .none
        options.deliveryMode = .opportunistic

        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 2000.0, height: 2000.0),
                             contentMode: .aspectFit,
                             options: options)
        { [weak self] result, _ in
            guard let image = result else { return }
            self?.outfitImage.value = image

            completion(result)
        }
    }

    func getPhotoCount() -> Int {
        return photoLibraryImages.count
    }
}
