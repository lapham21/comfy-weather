//
//  UINavigationController+ComfyWeather.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/5/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setupForAddOutfitsStack() {
        guard let chivoBold = UIFont.chivo(size: 14, style: .bold) else { return }
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName: chivoBold
        ]
        navigationBar.barTintColor = UIColor.comfyMauveColor
        navigationBar.tintColor = UIColor.white
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "navExitMenuWhite")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "navExitMenuWhite")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func setupforHomeScreen() {
        guard let chivoBoldFont = UIFont.chivo(size: 14.0) else { return }

        // Remove navigation bar's bottom divider
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.white
        navigationBar.tintColor = UIColor.comfyDarkBlueColor

        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.comfyDarkBlueColor,
            NSFontAttributeName : chivoBoldFont
        ]
    }
    
    func setupForPreviousOutfitsStack() {
        guard let chivoBold = UIFont.chivo(size: 14, style: .bold) else { return }
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName: chivoBold
        ]
        navigationBar.barTintColor = UIColor.comfyCoolGreyColor
        navigationBar.tintColor = UIColor.white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
