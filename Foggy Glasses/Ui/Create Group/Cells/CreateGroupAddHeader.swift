//
//  CreateGroupAddHeader.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/24/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class CreateGroupAddHeader: UICollectionViewCell {
    
    static let id = "Create Group Add Header Cell ID"
    
    ///Count of users in group
    var count = 0 {
        didSet {
            members.text = "Group Members (\(count))"
        }
    }
    
    var addButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Add People To Group")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    let members: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(addButton)
        addButton.withSize(width: 101, height: 31)
        addButton.centerVertically(in: self)
        addButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        addButton.addTarget(self, action: #selector(openAddPeople), for: .touchUpInside)
        
        addSubview(members)
        members.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: addButton.rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 8, paddingRight: 18, width: 0, height: 0)
        members.text = "Group Members (\(count))"
    }
    
    @objc func openAddPeople(){
        NotificationCenter.default.post(name: CreateGroupController.addPeopleNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
