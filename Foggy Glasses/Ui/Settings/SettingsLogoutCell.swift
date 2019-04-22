//
//  SettingsLogoutCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/22/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PopupDialog

class SettingsLogoutCell: UICollectionViewCell {
    static let height: CGFloat = 82
    static let id = "Settings Logout cell Id"
    var group:FoggyGroup?
    var leaveGroup = false {
        didSet {
            if leaveGroup {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
                button.setTitle("Leave Group", for: .normal)
                button.removeTarget(self, action: #selector(signOutClicked), for: .touchUpInside)
                button.addTarget(self, action: #selector(leaveGroupClicked), for: .touchUpInside)
            }
        }
    }
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .white
        view.setTitleColor(.black, for: .normal)
        view.setTitle("Logout", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        view.addTarget(self, action: #selector(signOutClicked), for: .touchUpInside)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 38, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func leaveGroupClicked() {
        //TODO: Implement leave group logic
        print("Leave Group")
        let popup = PopupDialog(title: "Leave Group", message: "Are you sure you wish to leave this group?")
        let confirm = PopupDialogButton(title: "Confirm") {
            guard let group  = self.group, let uid = Auth.auth().currentUser?.uid else { return }
            FirebaseManager.global.leaveGroup(group: group, uid: uid) { (left) in
                if left {
                    
                    print("Successfully left group")
                    if let parentController = self.parentViewController as? GroupSettingsController {
                        DispatchQueue.main.async {
                            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
                            parentController.navigationController?.pushViewController(feed, animated: true)
                            
                        }
                        //                    parentController.clickedHome()
                        
                    }
                    
                } else {
                    print("Error leaving group")
                }
            }
        }
        confirm.defaultTitleColor = .red
        let decline = PopupDialogButton(title: "Decline") {
            
        }
        decline.defaultTitleColor = .black
        popup.addButtons([confirm, decline])
        if let parent = parentViewController {
            parent.present(popup, animated: true, completion: nil)
            return
        }
        
        
        //        print("Leave Group")
//        guard let group  = group, let uid = Auth.auth().currentUser?.uid else { return }
//        FirebaseManager.global.leaveGroup(group: group, uid: uid) { (left) in
//            if left {
//
//                print("Successfully left group")
//                if let parentController = self.parentViewController as? GroupSettingsController {
//                    DispatchQueue.main.async {
//                        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
//                        parentController.navigationController?.pushViewController(feed, animated: true)
//
//                    }
////                    parentController.clickedHome()
//
//                }
//
//            } else {
//                print("Error leaving group")
//            }
//        }
//        if let parentController = parentViewController {
//            let popup = PopupDialog(title: "Leave Group", message: "This feature has not been implemented yet :)")
//            parentController.present(popup, animated: true, completion: nil)
//        }
        
    }
    
    @objc private func signOutClicked() {
        
        do {
            try? Auth.auth().signOut()
            
            //            iterateKeychainItems(log: true, delete: true)
            FeedHideManager.global.refreshUser()
            FirebaseManager.global.friends.removeAll()
            
            let welcome = WelcomeController()
            let nav = UINavigationController(rootViewController: welcome)
            if let presenter = parentViewController {
                presenter.present(nav, animated: true, completion: nil)
            }
            
            
            removeUidFromPersistentContainer()
        }
        
    }
    
    private func removeUidFromPersistentContainer(){
        let shared = UserDefaults.init(suiteName: sharedGroup)
        shared?.removeObject(forKey: "Firebase User Id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
