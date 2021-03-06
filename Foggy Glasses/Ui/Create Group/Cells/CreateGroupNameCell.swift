//
//  CreateGroupNameCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class CreateGroupNameCell: UICollectionViewCell, UITextFieldDelegate {
    static let id = "CreateGroupNameCellId"
    
    //MARK: UI Elements
    var groupName: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Group Name"
        v.headerString = "Group Name"
        v.headerTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(groupName)
        groupName.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        groupName.addTarget(self, action: #selector(textChanged(tf:)), for: .editingChanged)
    }
    
    @objc func textChanged(tf: UITextField) {
        print(groupName.text)
        if let text = groupName.text {
            let data = ["name":text]
            NotificationCenter.default.post(name: CreateGroupController.groupNameNotification, object: data)
//            let link = ["link":groupName.text]
//            NotificationCenter.default.post(name: QuickshareController.articleLinkNotification, object: link)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
