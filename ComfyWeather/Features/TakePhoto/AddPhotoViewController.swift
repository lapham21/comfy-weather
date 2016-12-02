//
//  AddPhotoViewController.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import Photos

final class AddPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var viewModel: OutfitPhotoViewModel?
    private var screenSize: CGRect?
    private var screenWidth: CGFloat?
    private var screenHeight: CGFloat?
    private let reuseIdentifier = "Photo Cell"
    var takePhotoViewController = TakePhotoViewController()

    @IBOutlet weak var collectionView: UICollectionView!

    @IBAction func takePhotoButtonPressed(_ sender: UITapGestureRecognizer) {
        navigationController?.navigationItem.leftBarButtonItem?.title = ""
        takePhotoViewController.viewModel = viewModel
        self.navigationController?.pushViewController(takePhotoViewController, animated: true)
    }

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        screenSize = UIScreen.main.bounds
        guard let screenSize = screenSize else { return }
        screenWidth = screenSize.width - 4

        navigationItem.title = "ADD PHOTO"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        determinePhotoRollAccess()
    }

    private func determinePhotoRollAccess() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            getImages()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status ==  .authorized {
                        self?.getImages()
                    }
                }
            }
        default: break
        }
    }

    private func getImages() {
        viewModel?.getPhotoLibrary() {
            DispatchQueue.main.async { [weak self] in
                guard let welf = self else { return }
                welf.collectionView?.reloadData()
            }
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getPhotoCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let photoCell = cell as? PhotoCollectionViewCell else { return cell }

        photoCell.imageView.image = viewModel?.getPhoto(for: indexPath)
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell else { return }
        cell.activityView.isHidden = false

        viewModel?.setPhoto(for: indexPath) { [weak self] image in
            DispatchQueue.main.async { [weak self] in
                cell.activityView.isHidden = true

                if image != nil {
                    let _ = self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let screenWidth = screenWidth
            else { return CGSize(width: 50, height: 50) }
            return CGSize(width: screenWidth/3, height: screenWidth/3)
        }
}
