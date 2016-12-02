//
//  UILabel+Typography.swift
//  ComfyWeather
//
//  Created by MIN BU on 10/3/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

extension UILabel {
    
    /**
     Sets the text of the UILabel instance to an attributed string with tracking applied
     - Parameter value: The value in points that each character is kerned to
     */
    
    public func ip_setCharacterSpacing(value: CGFloat) {
        addAttribute(attr: NSKernAttributeName, value: value as AnyObject)
    }
    
    /**
     Sets the text of the UILabel instance to an attributed string with the specified line spacing
     - Parameter value: The space, in points, between each line.
     */
    
    public func ip_setLineSpacing(value: CGFloat) {
        let paragraphSpacing = NSMutableParagraphStyle()
        paragraphSpacing.lineSpacing = value
        paragraphSpacing.alignment = textAlignment
        addAttribute(attr: NSParagraphStyleAttributeName, value: paragraphSpacing)
    }
    
    // MARK: Private
    
    private func addAttribute(attr: String, value: AnyObject) {
        let attrText = mutableAttributedText()
        attrText.addAttributes([attr:value], range: NSMakeRange(0, attrText.length))
        text = nil
        attributedText = attrText
    }
    
    public func ip_setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight - 2
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.alignment = textAlignment
        addAttribute(attr: NSParagraphStyleAttributeName, value: paragraphStyle)
    }
    
    private func baseAttributes() -> [String:AnyObject] {
        return [NSFontAttributeName : font, NSForegroundColorAttributeName : textColor]
    }
    
    private func mutableAttributedText() -> NSMutableAttributedString {
        let bareText = text ?? ""
        
        if let attributedText = attributedText {
            return NSMutableAttributedString(attributedString: attributedText)
        } else {
            return NSMutableAttributedString(string: bareText, attributes: self.baseAttributes())
        }
    }
    
}
