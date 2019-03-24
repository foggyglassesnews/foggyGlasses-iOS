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
    var member: SearchMember? {
        didSet {
            if let user = member {
                let attr = NSMutableAttributedString(string: user.name + "\n", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)])
                attr.append(NSAttributedString(string: user.detail, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)]))
                name.attributedText = attr
//                name.text = user.name + "\n" + user.detail
            }
        }
    }
    
    var uid: String? {
        didSet {
            if let uid = uid {
                FirebaseManager.global.getFoggyUser(uid: uid) { (user) in
                    var member = SearchMember()
                    member.foggyUser = user
                    self.member = member
                }
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
        
        sideSelect.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
