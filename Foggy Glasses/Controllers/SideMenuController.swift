//
//  SideMenuController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts

class SideMenuController: UIViewController {
    
    //MARK: UI Elements
    var bg: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Welcome BG")
        return v
    }()
    
    var logo: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Side Logo")
        return v
    }()
    
    var createGroup: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Create A Group")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        
        //BG
        view.addSubview(bg)
        bg.pin(in: view)
        
        view.addSubview(logo)
        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 70, height: 80)
        logo.centerHoriziontally(in: view)
        
        view.addSubview(createGroup)
        createGroup.anchor(top: logo.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 154, height: 41)
        createGroup.centerHoriziontally(in: view)
        createGroup.addTarget(self, action: #selector(clickedCreateGroup), for: .touchUpInside)
        
    }
    
    @objc func clickedCreateGroup() {
        if checkForContactPermission() {
            navigationController?.pushViewController(CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        } else {
            navigationController?.pushViewController(ContactPermissionController(), animated: true)
        }
    }
    
    private func checkForContactPermission() -> Bool {
        let authroizationType = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Type:", authroizationType)
        if authroizationType == .notDetermined || authroizationType == .denied || authroizationType == .restricted {
            return false
        }
        return true
        
        //        CNContactStore.init().requestAccess(for: .contacts) { (access, err) in
        //            if let err = err {
        //                print("Error requesting contacts:", err.localizedDescription)
        //                return
        //            }
        //            print("Contact Access:", access.description)
        //
        //        }
    }
}
