//
//  PermissionLocationViewController.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/6/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import CoreLocation

final class PermissionLocationViewController: UIViewController, UIViewControllerTransitioningDelegate, LocationServiceDelegate {
    
    // MARK: IBOutlet
    @IBOutlet weak var okayButton: UIButton!
    
    // MARK: IBAction
    @IBAction func okayButtonPressed(_ sender: UIButton) {
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    override func viewDidLoad() {
        LocationService.sharedInstance.delegate = self
        LocationService.sharedInstance.startUpdatingLocation()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = BlurModalPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.presentedViewWidth = 325.0
        presentationController.presentedViewHeight = 325.0
        
        return presentationController
    }
    
    // MARK: LocationServiceDelegate
    internal func tracingLocation(currentLocation: CLLocation) {
        self.dismiss(animated: true, completion: {});
    }
    
    internal func tracingLocationDidFailWithError(error: NSError) {
    }

}
