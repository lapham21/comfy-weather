//
//  UICollectionView+RegisterNib.swift
//  ComfyWeather
//
//  Created by Son Le on 10/15/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UICollectionView {

    func registerNib<T: UICollectionViewCell>
        (of type: T.Type, bundle: Bundle? = nil, forCellWithReuseIdentifier identifier: String? = nil) {
        let nib = UINib(nibName: "\(type)", bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier ?? "\(type)")
    }

    func registerNib<T: UICollectionReusableView>
        (of type: T.Type,
         bundle: Bundle? = nil,
         forSupplementaryViewOfKind elementKind: String,
         withReuseIdentifier identifier: String? = nil) {
        let nib = UINib(nibName: "\(type)", bundle: bundle)
        register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier ?? "\(type)")
    }

}
