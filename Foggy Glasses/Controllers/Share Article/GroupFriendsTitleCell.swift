//
//  GroupFriendsTitleCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class GroupFriendsTitleCell: UICollectionViewCell {
    static let id = "Group Friends Title Cell ID"
    
    var titleString = "" {
        didSet{
            label.text = titleString
        }
    }
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.anchor(top: centerYAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 11, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
