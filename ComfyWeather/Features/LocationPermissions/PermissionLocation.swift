//
//  PermissionLocation.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/6/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class PermissionLocation: UIView {

    // MARK: IBOutlet
    @IBOutlet weak var whoopsLabel: UILabel!
    @IBOutlet weak var whoopsContentLabel: UILabel!
    @IBOutlet weak var okayButton: UIButton!
    
    override func layoutSubviews() {
        whoopsLabel.ip_setCharacterSpacing(value: 0.5)
        whoopsContentLabel.ip_setCharacterSpacing(value: 0.3)
        whoopsContentLabel.ip_setLineHeight(lineHeight: 20.0)
        guard let title = okayButton.titleLabel?.text else {return}
        let attributedTitle = NSAttributedString(string: title, attributes: [NSKernAttributeName: 0.5])
        okayButton.setAttributedTitle(attributedTitle, for: .normal)
    }

}
