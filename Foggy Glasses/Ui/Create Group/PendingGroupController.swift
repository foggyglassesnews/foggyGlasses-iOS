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
    var groupFeed: FoggyGroup? {
        didSet {
            print("Set Pending Group")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .feedBackground
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.setTitleColor(.black, for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptInvitation), for: .touchUpInside)
        
        view.addSubview(denyButton)
        denyButton.anchor(top: acceptButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        denyButton.setTitle("Deny", for: .normal)
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
