//
//  EmptyHomeFeed.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class EmptyHomeFeed: UIView {
    let image = UIImageView(image: UIImage(named: "Foggy Main Icon"))
    let message = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageContainer = UIView()
        addSubview(imageContainer)
        imageContainer.anchor(top: topAnchor, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(image)
        image.contentMode = .scaleAspectFill
        image.withSize(width: 129, height: 115)
        image.center(in: imageContainer)
        image.flash(animation: .scale)
        
        
        addSubview(message)
        message.withSize(width: 272, height: 70)
        message.center(in: self)
        message.textColor = .black
        message.numberOfLines = 0;
        message.textAlignment = .center
        message.font = UIFont.systemFont(ofSize: 22, weight: .light)
        
        message.sizeToFit()
        
        
    }
    
    func message(message: String) {
        self.message.text = message
        return
        let attributedString = NSMutableAttributedString(string: message)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 8 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.message.attributedText = attributedString
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class LoadingHomeFeed: UIView {
    let image = UIActivityIndicatorView()
    let message = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageContainer = UIView()
        addSubview(imageContainer)
        imageContainer.anchor(top: topAnchor, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(image)
        image.contentMode = .scaleAspectFill
        image.withSize(width: 129, height: 115)
        image.center(in: imageContainer)
        image.startAnimating()
        image.color = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
