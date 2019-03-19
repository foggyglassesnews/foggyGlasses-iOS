//
//  PendingGroupController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/18/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
class PendingGroupController:UIViewController {
    let acceptButton = UIButton()
    let denyButton = UIButton()
    let groupTitle = UILabel()
    var groupFeed: FoggyGroup? {
        didSet {
            guard let groupFeed = groupFeed else { return }
            groupTitle.text = "@\(groupFeed.adminId) invited you to join\n\(groupFeed.name)."
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
        
    }
    
    @objc func denyInvitation() {
        print("Denied Invitaiton")
    }
}
