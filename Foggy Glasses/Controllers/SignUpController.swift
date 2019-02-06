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

class SignUpController: UIViewController {
    
    //MARK: UI Elements
    var scroller = UIScrollView()
    
    var loginButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Already Have Account")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var nameTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Name"
        v.headerString = "Name"
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
    
    //MARK: UI Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Up"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
        
        loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
    }
    
    func configNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar Background")?.withRenderingMode(.alwaysOriginal), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(signUp))
        
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func configUI() {
        view.addSubview(scroller)
        scroller.pin(in: view)
        scroller.alwaysBounceVertical = true
        scroller.keyboardDismissMode = .onDrag
        
        scroller.addSubview(loginButton)
        loginButton.anchor(top: scroller.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 282, height: 43)
        loginButton.centerHoriziontally(in: view)
        
        let padding: CGFloat = 42
        
        scroller.addSubview(nameTxt)
        nameTxt.anchor(top: loginButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        scroller.addSubview(usernameTxt)
        usernameTxt.anchor(top: nameTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        scroller.addSubview(emailTxt)
        emailTxt.anchor(top: usernameTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        scroller.addSubview(passwordTxt)
        passwordTxt.anchor(top: emailTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: padding, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        for txtField in [nameTxt, usernameTxt, emailTxt, passwordTxt]{
            txtField.delegate = self
        }
        
    }

    ///Sign up button clicked target method
    @objc func signUp() {
        resignAllTextFields()
        validateInputs()
    }
    
    ///Transitions to Login Controller
    @objc func loginClicked() {
        let login = LoginController()
        navigationController?.pushViewController(login, animated: true)
    }
    
    ///Method for validating inputs
    private func validateInputs() {
        //Validate name
        if let name = nameTxt.text {
            if name.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a name.")
                return
            }
        } else {
            displayError(title: "Sign Up Error", error: "Please provide a name.")
            return
        }
        
        //Validate username
        if let username = usernameTxt.text {
            if username.isEmpty {
                displayError(title: "Sign Up Error", error: "Please provide a Username.")
                return
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
            
            print("Successfully created account!")
            self.showFeed()
        }

    }
    
    private func showFeed() {
        let feed = FeedController()
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
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTxt || textField == passwordTxt {
            scroller.contentOffset = CGPoint(x: 0, y: 100)
        } else {
            scroller.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    //Resets scrollview offset
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        scroller.contentOffset = CGPoint(x: 0, y: 0)
        return true
    }
    
    ///Helper method to dimiss all keyboards
    private func resignAllTextFields() {
        for t in [nameTxt, usernameTxt, emailTxt, passwordTxt] {
            t.resignFirstResponder()
        }
        scroller.contentOffset = CGPoint(x: 0, y: 0)
    }
}
