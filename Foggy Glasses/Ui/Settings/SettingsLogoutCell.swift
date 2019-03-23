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

class SettingsLogoutCell: UICollectionViewCell {
    static let height: CGFloat = 82
    static let id = "Settings Logout cell Id"
    
    
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
    
    @objc private func signOutClicked() {
        do {
            try? Auth.auth().signOut()
            
            //            iterateKeychainItems(log: true, delete: true)
            FeedHideManager.global.refreshUser()
            
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
