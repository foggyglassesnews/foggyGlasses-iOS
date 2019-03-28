//
//  Constants.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/5/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

extension UIColor {
    static let foggyBlue = UIColor(red:0.79, green:0.86, blue:1.00, alpha:1.0)
    static let foggyGrey = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
    
    static let feedBackground = UIColor(red:0.93, green:0.93, blue:0.94, alpha:1.0)
    static let joinBackground = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.0)
    static var placeholder: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }
    
    static let buttonBlue = UIColor(red:0.22, green:0.54, blue:0.89, alpha:1.0)
}

extension UIFont {
    func withTraits(traits:UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}
