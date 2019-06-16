//
//  ContactPermissionController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/8/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Contacts
import PopupDialog
import SafariServices

class ContactPermissionController: UIViewController {
    //MARK: UI Elements
    var contactImage: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Contacts Image")
        return v
    }()
    
    var contactText: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "Contact Text")
        return v
    }()
    
    var contactAllow: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Contact Allow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var privacy: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Privacy Policy")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var isFromQuickshare = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .feedBackground
        
        view.addSubview(contactImage)
        contactImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 201, height: 201)
        contactImage.centerHoriziontally(in: view)
        
        view.addSubview(contactText)
        contactText.anchor(top: contactImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: view.frame.height / 4)
        
        view.addSubview(contactAllow)
        contactAllow.anchor(top: contactText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 32, paddingLeft: 0, paddingBottom: 32, paddingRight: 0, width: 154, height: 41)
        contactAllow.centerHoriziontally(in: view)
        contactAllow.addTarget(self, action: #selector(requestContacts), for: .touchUpInside)
        
        view.addSubview(privacy)
        privacy.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 8, paddingRight: 30, width: 0, height: 30)
        privacy.addTarget(self, action: #selector(clickedPrivacy), for: .touchUpInside)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func clickedPrivacy() {
        let safariVC = SafariController(url: URL(string: "https://www.privacypolicies.com/privacy/view/916e29b57ccbb302841729f22babfe51")!)
        present(safariVC, animated: true, completion: nil)
        
    }
    
    @objc func requestContacts() {
        //If user denied or restricted open the settings
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .restricted || status == .denied {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        
        //Request access if not
        CNContactStore.init().requestAccess(for: .contacts) { (access, err) in
            if let err = err {
                print("Error:", err.localizedDescription)
                return
            }
            
            if access {
                self.presentNext()
            }
        }
    }
    
    func presentNext() {
        DispatchQueue.main.async {
            let create = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
            create.isSkipEnabled = false
            create.isFromQuickshare = self.isFromQuickshare
            self.navigationController?.pushViewController(create, animated: true)
        }
        
        
    }
    
}
