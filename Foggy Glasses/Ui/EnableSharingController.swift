//
//  EnableSharingController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/2/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class EnableSharingController: UIViewController {
    
    let nextButton = UIButton(type: .system)
    let image = UIImageView(image: UIImage(named: "Enable Sharing"))
    
    var fromSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Enable Sharing"
        configNavigationBar()
        
        view.backgroundColor = .white
        
        if !fromSettings {
            view.addSubview(nextButton)
            nextButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 100, height: 50)
            nextButton.centerHoriziontally(in: view)
            nextButton.setTitle("Next", for: .normal)
            nextButton.setTitleColor(.black, for: .normal)
            nextButton.layer.cornerRadius = 25
            nextButton.backgroundColor = .foggyBlue
            nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            nextButton.addTarget(self, action: #selector(clickedNext), for: .touchUpInside)
            
            image.contentMode = .scaleAspectFit
            view.addSubview(image)
            image.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nextButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
            
            navigationItem.hidesBackButton = true
            navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = .black
            
        } else {
            image.contentMode = .scaleAspectFit
            view.addSubview(image)
            image.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
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
        if checkForContactPermission() {
            let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
            create.isSkipEnabled = true
            self.navigationController?.pushViewController(create, animated: true)
        } else {
            let contact = ContactPermissionController()
            navigationController?.pushViewController(contact, animated: true)
        }
    }
}
