//
//  FeedController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase

class FeedController: UIViewController {
    
    //MARK: UI Elements
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
    }
    
    func configNav() {
        configNavigationBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func configUI() {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Firebase account created! Account ID\n\(Auth.auth().currentUser!.uid)"
        view.addSubview(label)
        label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 100)
        label.textAlignment = .center
        
        let signOUt = UIButton(type: .system)
        signOUt.setTitle("Sign Out", for: .normal)
        signOUt.addTarget(self, action: #selector(signoutClicked), for: .touchUpInside)
        view.addSubview(signOUt)
        signOUt.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    
    @objc func signoutClicked() {
        
        do {
            try? Auth.auth().signOut()
            let welcome = WelcomeController()
            present(welcome, animated: true, completion: nil)
        }
    }
}

