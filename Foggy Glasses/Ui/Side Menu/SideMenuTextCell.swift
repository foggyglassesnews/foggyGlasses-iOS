//
//  SideMenuTextCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SideMenuTextCell: UICollectionViewCell {
    static let id = "SideMenuTextCellID"
    
    var text: String! {
        didSet {
            label.text = text
        }
    }
    
    var label: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        v.textColor = .white
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
