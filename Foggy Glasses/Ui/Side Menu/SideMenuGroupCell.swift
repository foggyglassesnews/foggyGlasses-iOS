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
    
    var glasses: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "Glasses")
        return v
    }()
    
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
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 55, width: 0, height: 0)
        
        hasNotifications(bool: false)
        
        let bottomDiv = UIView()
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDiv.backgroundColor = .joinBackground
    }
    
    func hasNotifications(bool: Bool) {
        if bool {
            sideSelect.removeFromSuperview()
            glasses.removeFromSuperview()
            
            addSubview(glasses)
            glasses.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 50, height: 0)
            
            addSubview(sideSelect)
            sideSelect.anchor(top: nil, left: nil, bottom: nil, right: glasses.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 25, height: 25)
            sideSelect.centerVertically(in: self)
        } else {
            sideSelect.removeFromSuperview()
            glasses.removeFromSuperview()
        
            addSubview(sideSelect)
            sideSelect.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: 4, paddingRight: 16, width: 25, height: 25)
            sideSelect.centerVertically(in: self)
        }
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
