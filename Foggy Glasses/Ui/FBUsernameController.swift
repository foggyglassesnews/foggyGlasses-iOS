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
import FirebaseAuth
import PopupDialog

class FBUsernameController: UIViewController {
    
    var firstName: String?
    var lastName: String?
    var email: String?
    
    var validUser = false
    
    //MARK: UI Elements
    var usernameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Username"
        v.headerString = "Create A Username"
        v.autocorrectionType = .no
        return v
    }()
    
    lazy var createAccount: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Create Account", for: .normal)
        v.backgroundColor = .buttonBlue
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        v.setTitleColor(.white, for: .normal)
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        v.addTarget(self, action: #selector(createAccountClicked), for: .touchUpInside)
        return v
    }()
    
    let logo = UIImageView(image: UIImage(named: "Verification Logo"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Join"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
//        view.addGestureRecognizer(tap)
//        view.isUserInteractionEnabled = true
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func configNav() {
        configNavigationBar()
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(loginClicked))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func configUI() {
//        view.addSubview(logo)
//        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 145)
//        logo.centerHoriziontally(in: view)
        
        
        view.addSubview(usernameTxt)
        usernameTxt.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 42, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        usernameTxt.addTarget(self, action:
            #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        view.addSubview(createAccount)
        createAccount.anchor(top: usernameTxt.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
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
        guard let firstName = firstName, let last = lastName, let uid = Auth.auth().currentUser?.uid, let userName = usernameTxt.text?.lowercased() else {
            return
        }

        let data = ["firstName":firstName, "lastName":last, "userName": userName]
        
        FirebaseManager.global.createUser(uid: uid, data: data) { err in
            if let err = err {
                self.displayError(title: "Join Error", error: err.localizedDescription)
                return
            }
            self.verify(uid: uid)
            
        }
    }
    
    func verify(uid: String) {
        PhoneVerificationManager.shared.isPhoneVerified(uid: uid) { (verified) in
            if verified {
                self.navigationController?.pushViewController(FeedController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            } else {
                self.showValidate()
            }
        }
        
    }
    
    func showValidate() {
        let valid = EmailVerificationController()
        let first = firstName ?? "Foggy"
        let last = lastName ?? "User"
//        valid.fullName = first + " " + last
        let nav = UINavigationController(rootViewController: valid)
//        present(nav, animated: true, completion: nil)
        present(nav, animated: true) {
            valid.fullName = first + " " + last
        }
    }
    
    func acceptPendingFriend() {
        
        if let referId = UserDefaults.standard.string(forKey: "invitedby"), let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.makeFriends(senderId: referId, recieverId: uid) { (success) in
                print("Success!")
                
            }
        }
        
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
            .child(trimmedString.lowercased())
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

