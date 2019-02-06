//
//  LoginController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/5/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    //MARK: UI Elements
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
    
    var forgotPassword: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Forgot Password", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        v.setTitleColor(UIColor(red:0.59, green:0.63, blue:0.72, alpha:1.0), for: .normal)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
        
        forgotPassword.addTarget(self, action: #selector(forgotPasswordClicked), for: .touchUpInside)
    }
    
    func configNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar Background")?.withRenderingMode(.alwaysOriginal), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func forgotPasswordClicked() {
        let forgotPass = ForgotPasswordController()
        navigationController?.pushViewController(forgotPass, animated: true)
    }
    
    private func configUI() {
        view.addSubview(emailTxt)
        emailTxt.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 42, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        view.addSubview(passwordTxt)
        passwordTxt.anchor(top: emailTxt.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 42, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
        
        view.addSubview(forgotPassword)
        forgotPassword.anchor(top: passwordTxt.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 117, height: 14)
        forgotPassword.centerHoriziontally(in: view)
    }
    
    
    
}

