//
//  FoggyHeaderTextCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/9/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class FoggyHeaderTextCell: UICollectionViewCell {
    static let id = "FoggyHeaderTextCellId"
    
    var titleText = "Foggy Glasses" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    private var titleLabel: UILabel = {
       let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13)
        v.adjustsFontSizeToFitWidth = true
        v.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
