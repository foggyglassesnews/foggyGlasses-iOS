//
//  FBUsernameController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/18/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import PopupDialog

class FBUsernameController: UIViewController {
    
    var firstName: String?
    var lastName: String?
    
    var validUser = false
    
    //MARK: UI Elements
    var usernameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Username"
        v.headerString = "Create A Username"
        return v
    }()
    
    var createAccount: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Create Account", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        v.setTitleColor(.black, for: .normal)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Join"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
        
        createAccount.addTarget(self, action: #selector(createAccountClicked), for: .touchUpInside)
    }
    
    func configNav() {
        configNavigationBar()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(loginClicked))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func configUI() {
        view.addSubview(usernameTxt)
        usernameTxt.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 42, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        usernameTxt.addTarget(self, action:
            #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addSubview(createAccount)
        createAccount.anchor(top: usernameTxt.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 117, height: 14)
        createAccount.centerHoriziontally(in: view)
    }
    
    @objc func createAccountClicked() {
        validateInputs()
    }
    
    ///Method for validating inputs
    private func validateInputs() {
        
        if !validUser {
            displayError(title: "Join Error", error: "Please enter valid username!")
        }
        
        //Unwrap data
        guard let firstName = firstName, let last = lastName, let uid = Auth.auth().currentUser?.uid, let userName = usernameTxt.text else {
            return
        }

        let data = ["firstName":firstName, "lastName":last, "userName": userName]
        Firestore.firestore().collection("users").document(uid).setData(data) { (err) in
            if let err = err {
                print("Err")
                return
            }
            self.showFeed()
        }
    }
    
    private func showFeed() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav = UINavigationController(rootViewController: feed)
        present(nav, animated: true, completion: nil)
    }
    
    ///Present Error Popup dialog
    private func displayError(title: String, error: String) {
        print("Display Popup")
        let popup = PopupDialog(title: title, message: error)
        let gotIt = PopupDialogButton(title: "Okay") {
        }
        gotIt.tintColor = .black
        popup.addButton(gotIt)
        present(popup, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { return }
        
        let trimmedString = usernameCheck(str: text)
        textField.text = trimmedString
        
        if trimmedString.count < 3 {
            usernameTxt.noRight()
            self.validUser = false
            return
        }
        
        if trimmedString.last == "_" {
            usernameTxt.takenUsername()
            self.validUser = false
            return
        }
        
        usernameTxt.loading()
        
        Database.database().reference()
            .child("unames")
            .child(trimmedString)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    self.usernameTxt.takenUsername()
                    self.validUser = false
                } else {
                    self.usernameTxt.validUsername()
                    self.validUser = true
                }
            }) { err in
                print(err)
        }
    }
    
    //Trim username
    private func usernameCheck(str: String) ->String {
        var replaced = str.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "__", with: "_")
        
        if replaced.first == "_" {
            replaced.removeFirst()
        }
        
        return replaced.strip(set: Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890._"))
    }
    
}

