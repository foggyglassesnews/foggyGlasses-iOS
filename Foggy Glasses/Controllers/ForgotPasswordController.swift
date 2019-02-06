//
//  ForgotPasswordController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class ForgotPasswordController: UIViewController {
    
    //MARK: UI Elements
    var header: UIImageView = {
       let v = UIImageView(image: UIImage(named: "Forgot Pass Header"))
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var emailTxt: InsetTextField = {
        let v = InsetTextField()
        v.placeholder = "Email"
        v.headerString = "Email Address"
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Forgot Password"
        view.backgroundColor = .joinBackground
        
        configNav()
        configUI()
    }
    
    func configNav() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Bar Background")?.withRenderingMode(.alwaysOriginal), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: "Noteworthy", size: 17)!.bold()]
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(resetPassword))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.backBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func resetPassword() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configUI() {
        view.addSubview(header)
        header.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 216, height: 134)
        header.centerHoriziontally(in: view)
        
        view.addSubview(emailTxt)
        emailTxt.anchor(top: header.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 44)
    }
    
    
    
}
