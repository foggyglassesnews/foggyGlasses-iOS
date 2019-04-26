//
//  PendingGroupController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/18/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PopupDialog

class PendingGroupController:UIViewController {
    let acceptButton = UIButton()
    let denyButton = UIButton()
    let groupTitle = UILabel()
    let activityIndicator = UIActivityIndicatorView()
    
    var groupFeed: FoggyGroup? {
        didSet {
            guard let groupFeed = groupFeed else { return }
            groupTitle.text = "@\(groupFeed.adminUsername) invited you to join\n\(groupFeed.name)."
            print("Set Pending Group")
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .feedBackground
        
        let image = UIImageView(image: UIImage(named: "Foggy Main Icon"))
        view.addSubview(image)
        image.contentMode = .scaleAspectFill
        image.withSize(width: 129, height: 115)
        image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        image.centerHoriziontally(in: view)
        image.flash(animation: .scale)
        
        let newGroup = UILabel()
        view.addSubview(newGroup)
        newGroup.anchor(top: image.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 32, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 24)
        newGroup.font = UIFont.systemFont(ofSize: 20, weight: .black)
        newGroup.textAlignment = .center
        newGroup.text = "New Group Invitation"
        newGroup.textColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        
        view.addSubview(groupTitle)
        groupTitle.anchor(top: newGroup.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 50)
        groupTitle.textAlignment = .center
        groupTitle.textColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
        groupTitle.numberOfLines = 2
        groupTitle.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        groupTitle.adjustsFontSizeToFitWidth = true
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: groupTitle.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 32, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        acceptButton.centerHoriziontally(in: view)
        acceptButton.setTitle("Join", for: .normal)
        acceptButton.setTitleColor(.black, for: .normal)
        acceptButton.layer.cornerRadius = 8
        acceptButton.backgroundColor = .white
        acceptButton.addTarget(self, action: #selector(acceptInvitation), for: .touchUpInside)
        
        view.addSubview(activityIndicator)
        activityIndicator.anchor(top: acceptButton.topAnchor, left: acceptButton.leftAnchor, bottom: acceptButton.bottomAnchor, right: acceptButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        activityIndicator.color = .black
        activityIndicator.alpha = 0
        
        view.addSubview(denyButton)
        denyButton.anchor(top: acceptButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        denyButton.centerHoriziontally(in: view)
        denyButton.layer.cornerRadius = 8
        denyButton.setTitle("Reject", for: .normal)
        denyButton.backgroundColor = .white
        denyButton.setTitleColor(.black, for: .normal)
        denyButton.addTarget(self, action: #selector(denyInvitation), for: .touchUpInside)
    }
    
    @objc func acceptInvitation() {
        print("Accepted Invitation")
        acceptButton.isEnabled = false
        denyButton.isEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.1) {
            self.acceptButton.alpha = 0
            self.denyButton.alpha = 0
            self.activityIndicator.alpha = 1
        }
        if let group = groupFeed, let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.joinGroup(group: group, uid: uid) { (complete) in
                if complete {
                    
                    FoggyUserPreferences.shared.joinGroup(groupId: group.id)
                    NotificationCenter.default.post(name: SideMenuController.updateGroupsNotification, object: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    UIView.animate(withDuration: 0.1) {
                        self.acceptButton.alpha = 1
                        self.denyButton.alpha = 1
                        self.activityIndicator.alpha = 0
                    }
                    self.acceptButton.isEnabled = true
                    self.denyButton.isEnabled = true
                }
            }
        }
       
    }
    
    @objc func denyInvitation() {
        print("Denied Invitaiton")
        acceptButton.isEnabled = false
        denyButton.isEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.1) {
            self.acceptButton.alpha = 0
            self.denyButton.alpha = 0
            self.activityIndicator.alpha = 1
        }
        if let group = groupFeed, let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.rejectGroup(group: group, uid: uid) { (complete) in
                if complete {
                    NotificationCenter.default.post(name: SideMenuController.updateGroupsNotification, object: nil)
                    
                    self.canBlockUser()
                } else {
                    UIView.animate(withDuration: 0.1) {
                        self.acceptButton.alpha = 1
                        self.denyButton.alpha = 1
                        self.activityIndicator.alpha = 0
                    }
                    self.acceptButton.isEnabled = true
                    self.denyButton.isEnabled = true
                }
            }
        }
    }
    
    private func canBlockUser() {
        FirebaseManager.global.getFoggyFriends { (users) in
            var isFriend = false
            for user in users {
                //They are friends, do nothing
                if user.uid == self.groupFeed!.adminId {
                    isFriend = true
                }
            }
            
            if isFriend {
                self.navigationController?.popViewController(animated: true)
            } else {
                let popup = PopupDialog(title: "Do You Know \(self.groupFeed!.adminUsername)?", message: "Would you like to block this user from inviting you to more groups?")
                let block = PopupDialogButton(title: "Block", action: {
                    print("Block User")
                    self.navigationController?.popViewController(animated: true)
                })
                let cancel = PopupDialogButton(title: "Cancel", action: {
                    self.navigationController?.popViewController(animated: true)
                })
                popup.addButtons([block, cancel])
            }
            
        }
    }
}
