//
//  GroupFriendsTitleCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class GroupFriendsTitleCell: UICollectionViewCell {
    static let id = "Group Friends Title Cell ID"
    
    var titleString = "" {
        didSet{
            label.text = titleString
        }
    }
    
    private let label = UILabel()
    
    var newGroup = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let div = UIView()
        div.backgroundColor = .lightGray
        addSubview(div)
        div.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.4)
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 11, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        addSubview(newGroup)
        newGroup.setTitle("+ New Group", for: .normal)
        newGroup.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        newGroup.titleLabel?.adjustsFontSizeToFitWidth = true
        newGroup.backgroundColor = .white
        newGroup.layer.cornerRadius = 8
        newGroup.clipsToBounds = true
        newGroup.setTitleColor(.black, for: .normal)
        newGroup.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 7, paddingLeft: 0, paddingBottom: 7, paddingRight: 8, width: 130, height: 0)
        newGroup.isHidden = true
    }
    
    override func prepareForReuse() {
//        newGroup.removeFromSuperview()
        newGroup.isHidden = true
        
    }
    
    func myGroupsHeaderConfig() {
        newGroup.isHidden = false
        newGroup.addTarget(self, action: #selector(clickedNext), for: .touchUpInside)
    }
    
    func myFriendsHeaderConfig() {
        newGroup.isHidden = true
    }
    
    @objc func clickedAddFriend(){
        if let controller = parentViewController {
            let add = AddMemberTableController()
            add.searchConfig()
            controller.navigationController?.pushViewController(add, animated: true)
        }
        
    }
    
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
    }
    
    
    @objc func clickedNext() {
        if let controller = parentViewController {
            if checkForContactPermission() {
                let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
//                create.isSkipEnabled = true
                controller.navigationController?.pushViewController(create, animated: true)
            } else {
                let contact = ContactPermissionController()
                controller.navigationController?.pushViewController(contact, animated: true)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
