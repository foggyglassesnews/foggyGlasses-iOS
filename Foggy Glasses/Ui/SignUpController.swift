//
//  SignUpController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/5/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import PopupDialog
import Firebase
import FirebaseDatabase
import FirebaseAuth
class SignUpController: UIViewController {
    
    //MARK: UI Elements
    var scroller = UIScrollView()
    
    var firstNameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "First Name"
        v.headerString = "First Name"
        return v
    }()
    
    var lastNameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Last Name"
        v.headerString = "Last Name"
        return v
    }()
    
    var usernameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Username"
        v.headerString = "Username"
        return v
    }()
    
    var emailTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Email"
        v.headerString = "Email Address"
        return v
    }()
    
    var passwordTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Password"
        v.headerString = "Password"
        v.isSecureTextEntry = true
        return v
    }()
    
    var ageField: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Select Birthdate"
        v.clearButtonMode = .whileEditing
        v.headerString = "Age (Optional)"
        v.textColor = .black
        return v
    }()
    
    var createAccount: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Create Account", for: .normal)
        v.backgroundColor = .buttonBlue
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        v.setTitleColor(.white, for: .normal)
        v.layer.cornerRadius = 8
        v.clipsToBounds = true
        v.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        return v
    }()
    
    var datePicker: UIDatePicker?
    
    var keyboardHeight: CGFloat!
    var activeField: UITextField?
    var lastOffset: CGPoint!
    
    ///For username validaiton
    var validUsername = false
    
    //MARK: UI Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Up"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
        
        //Observe Keyboard Change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func configNav() {
        configNavigationBar()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(signUp))
//        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func configUI() {
        view.addSubview(scroller)
        scroller.pin(in: view)
        scroller.alwaysBounceVertical = true
        scroller.keyboardDismissMode = .onDrag
        
//        scroller.addSubview(loginButton)
//        loginButton.anchor(top: scroller.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 282, height: 43)
//        loginButton.centerHoriziontally(in: view)
        
        let padding: CGFloat = 42
        
        scroller.addSubview(firstNameTxt)
        firstNameTxt.addTarget(self, action:
            #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        firstNameTxt.anchor(top: scroller.topAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, paddingTop: 15 + 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 2.5, width: 0, height: 44)
        
        scroller.addSubview(lastNameTxt)
        lastNameTxt.addTarget(self, action:
            #selector(nameTextFieldDidChange(_:)), for: .editingChanged)
        lastNameTxt.anchor(top: firstNameTxt.topAnchor, left: view.centerXAnchor, bottom: firstNameTxt.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 2.5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let div = UIView()
        scroller.addSubview(div)
        div.anchor(top: firstNameTxt.topAnchor, left: nil, bottom: lastNameTxt.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 1, height: 0)
        scroller.centerHoriziontally(in: view)
        
        scroller.addSubview(usernameTxt)
        usernameTxt.addTarget(self, action:
            #selector(textFieldDidChange(_:)), for: .editingChanged)
        usernameTxt.autocorrectionType = .no
        usernameTxt.anchor(top: lastNameTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 2.5, width: 0, height: 44)
        
        //Config Date Picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        scroller.addSubview(ageField)
//        usernameTxt.addTarget(self, action:
//            #selector(textFieldDidChange(_:)), for: .editingChanged)
        ageField.anchor(top: usernameTxt.topAnchor, left: view.centerXAnchor, bottom: usernameTxt.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 2.5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        ageField.inputView = datePicker
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(dismissPicker))
        ageField.inputAccessoryView = toolBar
        
        scroller.addSubview(emailTxt)
        emailTxt.anchor(top: ageField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        scroller.addSubview(passwordTxt)
        passwordTxt.anchor(top: emailTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        scroller.addSubview(createAccount)
        createAccount.anchor(top: passwordTxt.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
        createAccount.centerHoriziontally(in: view)
        
        for txtField in [firstNameTxt, lastNameTxt, usernameTxt, ageField, emailTxt, passwordTxt]{
            txtField.delegate = self
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    var isCancelling = false
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("First")
        isCancelling = true
        return true
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        if isCancelling {
            isCancelling = false
            print("Is Cancelling")
            view.endEditing(true)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        ageField.text = dateFormatter.string(from: datePicker.date)
    }

    ///Sign up button clicked target method
    @objc func signUp() {
        resignAllTextFields()
        validateInputs()
    }
    
    ///Method for validating inputs
    private func validateInputs() {
        
        //Validate name
        if let name = firstNameTxt.text {
            if name.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a first name.")
                return
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide a first name.")
            return
        }
        
        if let name = lastNameTxt.text {
            if name.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a last name.")
                return
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide a last name.")
            return
        }
        
        //Validate username
        if let username = usernameTxt.text {
            if username.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a Username.")
                return
            } else if !validUsername {
                displayError(title: "Username Error", error: "Please select a valid Username")
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide a Username.")
            return
        }
        
        //Validate email
        if let email = emailTxt.text {
            if email.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide an Email.")
                return
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide an Email.")
            return
        }
        
        //Validate password
        if let password = passwordTxt.text {
            if password.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a password.")
                return
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide an password.")
            return
        }
        
        //Unwrap data
        guard let emailText = emailTxt.text, let passwordText = passwordTxt.text else {
             return
        }
        
        //Create user account
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { (result, err) in
            if let err = err {
                self.displayError(title: "Sign Up Error", error: err.localizedDescription)
                return
            }
            
            //Store user account data
            self.createAccount(uid: Auth.auth().currentUser?.uid, completion: { (err) in
                if let err = err {
                    self.displayError(title: "Sign Up Error", error: err.localizedDescription)
                }
                
                print("Successfully created account!")
                self.accountValidate()
            })
        }
    }
    
    func showValidate() {
        let valid = EmailVerificationController()
        let nav = UINavigationController(rootViewController: valid)
        present(nav, animated: true, completion: nil)
    }
    
    private func accountValidate() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        PhoneVerificationManager.shared.isPhoneVerified(uid: user.uid) { (verified) in
            if verified {
                
                self.showAddQuickshare()
            } else {
                self.showValidate()
            }
            
        }
        
//        if !user.isEmailVerified {
//            
////            user.sendEmailVerification { (err) in
////                if let err = err {
////                    print("err", err)
////                }
////                self.showValidate()
////            }
//        } else {
//            showAddQuickshare()
////            showFeed()
//        }
    }
    
    func createAccount(uid: String?, completion: @escaping FirebaseManager.CreateUserCompletion) {
        guard let firstName = firstNameTxt.text, let lastName = lastNameTxt.text, let userName = usernameTxt.text, let uid = uid else {
            self.displayError(title: "Sign Up Error", error: "Something went wrong, please re-enter data")
            return
        }
        
        //Get the optional date field
        var data: [String: Any]
        if let age = datePicker?.date.timeIntervalSince1970 {
            data = ["firstName":firstName, "lastName":lastName, "userName":userName, "age":age]
        } else {
            data = ["firstName":firstName, "lastName":lastName, "userName":userName]
        }
        
        FirebaseManager.global.createUser(uid: uid, data: data, completion: completion)
    }
    
    private func showAddQuickshare() {
        navigationController?.pushViewController(EnableSharingController(), animated: true)
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
    
}

///MARK: Text field delegate
extension SignUpController: UITextFieldDelegate {
    
    //Handles offset for scroll view displaying all textfields
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = scroller.contentOffset
        return true
    }
    
    
    //Resets scrollview offset
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        activeField = nil
        scroller.contentOffset = CGPoint(x: 0, y: 0)
        return true
    }
    
    ///Helper method to dimiss all keyboards
    private func resignAllTextFields() {
        for t in [firstNameTxt, lastNameTxt, usernameTxt, emailTxt, passwordTxt] {
            t.resignFirstResponder()
        }
        scroller.contentOffset = CGPoint(x: 0, y: 0)
    }
}

//MARK: Username Validation
extension SignUpController {
    
    @objc func nameTextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { return }
        
        let trimmedString = nameCheck(str: text)
        textField.text = trimmedString
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text, text != "" else { return }
        
        let trimmedString = usernameCheck(str: text)
        textField.text = trimmedString
        
        if trimmedString.count < 3 {
            usernameTxt.noRight()
            validUsername = false
            return
        }
        
        if trimmedString.containsBadWords() {
            validUsername = false
            usernameTxt.takenUsername()
            return
        }
        
        if trimmedString.last == "_" {
            usernameTxt.takenUsername()
            validUsername = false
            return
        }
        
        usernameTxt.loading()
        
        Database.database().reference()
            .child("unames")
            .child(trimmedString)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    self.usernameTxt.takenUsername()
                    self.validUsername = false
                } else {
                    self.validUsername = true
                    self.usernameTxt.validUsername()
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
    
    private func nameCheck(str: String)->String{
//        var replaced = str.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "__", with: "_")
//
//        if replaced.first == "_" {
//            replaced.removeFirst()
//        }
//
        return str.strip(set: Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ._ "))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            print("Keyboard height")
            
            // move if keyboard hide input field
            if let active = activeField {
                let y = active.frame.origin.y
                let height = active.frame.size.height
                let distanceToBottom = self.scroller.frame.size.height - y - height
                let collapseSpace = keyboardHeight - distanceToBottom
                
                if collapseSpace < 0 {
                    // no collapse
                    return
                }
                
                // set new offset for scroll view
                UIView.animate(withDuration: 0.3, animations: {
                    // scroll to the position above keyboard 10 points
                    self.scroller.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
                })
            }
            
        }
    }
}
