//
//  UITableView+RegisterNib.swift
//  ComfyWeather
//
//  Created by Son Le on 10/15/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UITableView {

    func registerNib<T: UITableViewCell>
        (of type: T.Type,
         bundle: Bundle? = nil,
         forCellWithReuseIdentifier identifier: String? = nil) {
        let nib = UINib(nibName: "\(type)", bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier ?? "\(type)")
    }

}
