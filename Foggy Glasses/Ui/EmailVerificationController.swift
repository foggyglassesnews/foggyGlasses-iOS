//
//  EmailVerificationController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import PopupDialog

class EmailVerificationController: UIViewController {
    
    var timer = Timer()
    
    //UI Elements
    let logo = UIImageView(image: UIImage(named: "Verification Logo"))
    let text = UIImageView(image: UIImage(named: "Verification Text"))
    let button = UIButton(type: .system)
    
    let welcomeText: UILabel = {
        let v = UILabel()
        v.numberOfLines = 2
        v.font = UIFont.boldSystemFont(ofSize: 18)
        v.adjustsFontSizeToFitWidth = true
        v.textAlignment = .center
        return v
    }()
    
    let detailText: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 16)
        v.adjustsFontSizeToFitWidth = true
        v.numberOfLines = 2
        v.textAlignment = .center
        return v
    }()
    
    lazy var useThisNumber: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Use this iPhone's number", for: .normal)
        v.backgroundColor = .buttonBlue
        v.setTitleColor(.white, for: .normal)
        return v
    }()
    
    lazy var userDiffNumber: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Verify a different phone number", for: .normal)
        v.backgroundColor = .feedBackground
        v.setTitleColor(.buttonBlue, for: .normal)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
//        title = "Verification"
        view.backgroundColor = .feedBackground
        
        view.addSubview(logo)
        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 145)
        logo.centerHoriziontally(in: view)
        
        view.addSubview(welcomeText)
        welcomeText.anchor(top: logo.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 18, paddingBottom: 0, paddingRight: 18, width: 0, height: 42)
        welcomeText.text = "Welcome, Ryan!\nrtemple@ramapo.edu"
        
        view.addSubview(detailText)
        detailText.anchor(top: welcomeText.bottomAnchor, left: welcomeText.leftAnchor, bottom: nil, right: welcomeText.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 38)
        detailText.text = "Easily connect with friends and family\nby verifying your phone number."
        
        view.addSubview(useThisNumber)
        useThisNumber.anchor(top: detailText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
        useThisNumber.layer.cornerRadius = 20.5
        useThisNumber.clipsToBounds = true
        useThisNumber.centerHoriziontally(in: view)
        
        view.addSubview(userDiffNumber)
        userDiffNumber.anchor(top: useThisNumber.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
        userDiffNumber.centerHoriziontally(in: view)
        
//        scheduledTimerWithTimeInterval()
        let app = UIApplication.shared
        
        //Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResume(notification:)), name: UIApplication.willEnterForegroundNotification, object: app)
    }
    
    @objc func sendEmailVerificationAgain(){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (err) in
            if let err = err{
                self.displayError(title: "Error", error: err.localizedDescription)
                return
            }
        })
    }
    
    @objc func applicationWillResume(notification: Notification){
        print("Resume")
        checkForVerification()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        checkForVerification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        print("Checking for verification")
        checkForVerification()
    }
    
    func checkForVerification() {
        Auth.auth().currentUser?.reload(completion: { (err) in
            self.showVerify()
        })
        
    }
    
    func showVerify() {
        if let user = Auth.auth().currentUser {
            if user.isEmailVerified {
                print("Verified!")
                navigationController?.pushViewController(EnableSharingController(), animated: true)
//                self.acceptPendingFriend()
                
            }
        }
    }
    
    func acceptPendingFriend() {
        if let referId = UserDefaults.standard.string(forKey: "invitedby"), let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.makeFriends(senderId: referId, recieverId: uid) { (success) in
                print("Success!")
                self.navigationController?.pushViewController(EnableSharingController(), animated: true)
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
    
}
