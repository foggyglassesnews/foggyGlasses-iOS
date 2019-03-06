//
//  SideMenuGroupCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SideMenuGroupCell: SelectionCell {
    static let id = "SideMenuGroupCellId"
    
    var group: FoggyGroup! {
        didSet {
            label.text = group.name
        }
    }
    
    var label: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        v.textColor = .black
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        let bottomDiv = UIView()
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDiv.backgroundColor = .joinBackground
    }
    
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                
//            }
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
