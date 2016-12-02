//
//  SavePhotoViewController.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 9/28/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class SavePhotoViewController: UIViewController {
    
    var viewModel: OutfitPhotoViewModel?
    var isFrontCameraBeingUsed = false
    var addOutfitViewController = AddOutfitViewController()

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func saveOutfitButtonPressed(_ sender: UIButton) {
        
        if let image = viewModel?.getPhotoForSavedPhotoViewController() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        let _ = navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.titleLabel?.font = UIFont.chivo(size: 14, style: .bold)
        
        navigationItem.title = "TAKE PHOTO"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        imageView.image = viewModel?.outfitImage.value
    }
}
