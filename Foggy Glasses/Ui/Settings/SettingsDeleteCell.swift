//
//  SettingsDeleteCell.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PopupDialog

class SettingsDeleteCell: UICollectionViewCell {
    static let height: CGFloat = 52
    static let id = "Settings Delete cell Id"
    
    
    private lazy var button: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .white
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Delete Account", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        view.addTarget(self, action: #selector(deleteAccountClicked), for: .touchUpInside)
        view.backgroundColor = UIColor(red: 231.0 / 255.0, green: 76.0 / 255.0, blue: 60.0 / 255.0, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .feedBackground
        
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc private func deleteAccountClicked() {
        //TODO: Implement all delete logic
//        if let parentController = parentViewController {
//
//                let popup = PopupDialog(title: "Delete Account", message: "This feature has not been implemented yet :)")
//            parentController.present(popup, animated: true, completion: nil)
//
//        }
//        return
        let currentUid = Auth.auth().currentUser?.uid ?? "tmp"
        PhoneVerificationManager.shared.deleteAccount(uid: currentUid) {
            Auth.auth().currentUser?.delete(completion: { (err) in
                if let err = err {
                    print("Error deleting account:", err.localizedDescription)
                    return
                }
                
                
                
                FeedHideManager.global.refreshUser()
                
                let welcome = WelcomeController()
                let nav = UINavigationController(rootViewController: welcome)
                if let presenter = self.parentViewController {
                    presenter.present(nav, animated: true, completion: nil)
                }
                
                self.removeUidFromPersistentContainer()
            })
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
