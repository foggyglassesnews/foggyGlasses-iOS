//
//  SignUpController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/5/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Up"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
        
        loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
    }
    
    func configNav() {
        navigationController?.navigationBar.backgroundColor = .red
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundImage(for: .default)
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar Background")?.withRenderingMode(.alwaysOriginal), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func loginClicked() {
        title = ""
        let login = LoginController()
        navigationController?.pushViewController(login, animated: true)
        title = "Sign Up"
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
    
    
    
}

extension SignUpController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTxt || textField == passwordTxt {
            scroller.contentOffset = CGPoint(x: 0, y: 100)
            if (self.view.frame.origin.y < 0) {
                return
            }
//            self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height)
        } else {
//            if (self.view.frame.origin.y != 0) {
//                return
//            }
            scroller.contentOffset = CGPoint(x: 0, y: 0)
//            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        scroller.contentOffset = CGPoint(x: 0, y: 0)
        return true
    }
}
