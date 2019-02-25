//
//  CreateGroupFoggyFriendCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/9/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class CreateGroupFoggyFriendCell: SelectionCell {
    static let id = "CreateGroupFoggyFriendCellId"
    
    ///Datasource
    var foggyUser: FoggyUser? {
        didSet {
            if let user = foggyUser {
                name.text = user.name + "\n" + user.username
            }
        }
    }
    
    //MARK: UI Elements
    var name: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.adjustsFontSizeToFitWidth = true
        v.numberOfLines = 2
        return v
    }()
    
    var inviteButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Invite Contact")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(name)
        name.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let bottomDiv = UIView()
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDiv.backgroundColor = .joinBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
