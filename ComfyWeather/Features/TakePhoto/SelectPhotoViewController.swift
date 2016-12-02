//
//  SelectPhotoViewController.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 9/30/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import AVFoundation

final class SelectPhotoViewController: UIViewController {
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        let takePhotoViewController = TakePhotoViewController()
        navigationController?.navigationItem.leftBarButtonItem?.title = ""
        self.navigationController?.pushViewController(takePhotoViewController, animated: true)
    }

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ADD PHOTO"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
