//
//  CreateGroupContactCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class CreateGroupContactCell: UICollectionViewCell {
    static let id = "CreateGroupContactCellId"
    
    var contact: CNContact? {
        didSet {
            if let contact = contact {
                var text = contact.givenName + " " + contact.familyName + "\n"
                if contact.phoneNumbers.count > 0 {
                    if let phoneNumber = contact.phoneNumbers.first {
                        text += phoneNumber.value.stringValue
                    }
                }
                name.text = text
            }
        }
    }
    
    var inviteButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Invite Contact")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    //MARK: UI Elements
    var name: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.adjustsFontSizeToFitWidth = true
        v.numberOfLines = 2
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(name)
        name.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let bottomDiv = UIView()
        addSubview(bottomDiv)
        bottomDiv.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDiv.backgroundColor = .joinBackground
        
        addSubview(inviteButton)
        inviteButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 56, height: 27)
        inviteButton.centerVertically(in: self)
        inviteButton.addTarget(self, action: #selector(selectedInvite), for: .touchUpInside)
    }
    
    @objc func selectedInvite() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
