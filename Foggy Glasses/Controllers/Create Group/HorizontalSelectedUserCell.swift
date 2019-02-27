//
//  HorizontalSelectedUserCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/25/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class HorizontalSelectedUserCell: UICollectionViewCell {
    static let id = "Horizontal Selected User Cell Id"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 21
        backgroundView.clipsToBounds = true
        
        addSubview(backgroundView)
        backgroundView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
