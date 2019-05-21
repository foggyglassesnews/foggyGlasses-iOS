//
//  EmailVerificationController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFunctions
import FirebaseAuth
import PopupDialog
import MessageUI
import Messages

class EmailVerificationController: UIViewController {
    
    var fullName: String? {
        didSet {
            if fullName == ""  {
                fullName = "Friend"
            }
            welcomeText.text = "Welcome, \(fullName ?? "Friend")!"
        }
    }
    
    var timer = Timer()
    
    var composeVC: MFMessageComposeViewController!
    
    var user: FoggyUser? {
        didSet {
            if let email = FirebaseManager.global.userEmail {
                welcomeText.text = "Welcome, \(user?.name ?? "Friend")!\n\(email)"
            }
            
        }
    }
    
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
        v.addTarget(self, action: #selector(sendSMS), for: .touchUpInside)
        return v
    }()
    
    lazy var skip: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Skip Phone Verification", for: .normal)
        v.backgroundColor = .feedBackground
        v.setTitleColor(.buttonBlue, for: .normal)
        v.addTarget(self, action: #selector(skipVerification), for: .touchUpInside)
        return v
    }()
    
    var loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        let rightButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(showVerify))
        rightButton.tintColor = .black
        navigationItem.rightBarButtonItem = rightButton
        view.backgroundColor = .feedBackground
        
        view.addSubview(logo)
        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 145)
        logo.centerHoriziontally(in: view)
        
        view.addSubview(welcomeText)
        welcomeText.anchor(top: logo.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 18, paddingBottom: 0, paddingRight: 18, width: 0, height: 42)
//        welcomeText.text = ""
        self.user = FirebaseManager.global.foggyUser
        
        view.addSubview(detailText)
        detailText.anchor(top: welcomeText.bottomAnchor, left: welcomeText.leftAnchor, bottom: nil, right: welcomeText.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 38)
        detailText.text = "Easily connect with friends and family\nby verifying your phone number."
        
        view.addSubview(useThisNumber)
        useThisNumber.anchor(top: detailText.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
        useThisNumber.layer.cornerRadius = 8
        useThisNumber.clipsToBounds = true
        useThisNumber.centerHoriziontally(in: view)
        
        
        view.addSubview(loadingIndicator)
        loadingIndicator.color = .black
        loadingIndicator.anchor(top: useThisNumber.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        loadingIndicator.centerHoriziontally(in: view)
        loadingIndicator.hidesWhenStopped = true
        
        let app = UIApplication.shared
        
        //Register for the applicationWillResignActive anywhere in your app.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResume(notification:)), name: UIApplication.willEnterForegroundNotification, object: app)
        
        showVerify()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            // do stuff 42 seconds later
            DispatchQueue.main.async {
                self.view.addSubview(self.skip)
                self.skip.anchor(top: self.useThisNumber.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 225, height: 41)
                self.skip.centerHoriziontally(in: self.view)

            }
        }
    }
    
    @objc func skipVerification() {
        //Manually verify number with +1-skip-uid
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        PhoneVerificationManager.shared.skipVerify(uid: uid)
        Functions.functions().httpsCallable("skipVerification").call { (result, err) in
            print("Result", result, "Err", err)
        }
    }
    
    @objc func diffNumber() {
        let popup = PopupDialog(title: "Error", message: "Entering different number not implemented yet :)")
        present(popup, animated: true, completion: nil)
    }
    
    @objc func sendSMS() {
        
        self.composeVC = MFMessageComposeViewController()
        self.composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        self.composeVC.recipients = [firebasePhoneNumber]
        self.composeVC.body = "Send this text to verify this phone number: (\(Auth.auth().currentUser?.uid ?? ""))"
        self.composeVC.disableUserAttachments()
        
        // Present the view controller modally.
        self.present(self.composeVC, animated: true, completion: nil)
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
        showVerify()
    }
    
    @objc func showVerify() {
    
        if let uid = Auth.auth().currentUser?.uid  {
            
            PhoneVerificationManager.shared.isPhoneVerified(uid: uid) { (verified) in
                if verified {
                    self.timer.invalidate()
                    
                    FirebaseManager.global.userEmail = nil
                    
                    if let _ = self.navigationController?.visibleViewController as? EnableSharingController {
                        //Dont push vc
                    } else {
                        self.navigationController?.pushViewController(EnableSharingController(), animated: true)
                    }
                } else {
                    PhoneVerificationManager.shared.isValidPhoneNumber(uid: uid) { (numberTaken) in
                        if numberTaken {
                            let popup = PopupDialog(title: "Verification Error", message: "Phone number is already in use")
                            self.present(popup, animated: true, completion: {
                                PhoneVerificationManager.shared.removeisValidNumber(uid: uid, completion: { (removed) in
                                    self.timer.invalidate()
                                    self.loadingIndicator.stopAnimating()
                                    
                                    
                                    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .done, target: self, action: #selector(self.restartSignup))
                                    self.navigationItem.leftBarButtonItem?.tintColor = .black
                                    
                                    print("Removing", removed)
                                })
                            })
                        }
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
            
            
        }
    }
    @objc func restartSignup() {
        Auth.auth().currentUser?.delete(completion: { (err) in
            DispatchQueue.main.async {
                let welcome = WelcomeController()
                let nav = UINavigationController(rootViewController: welcome)
                self.present(nav, animated: true, completion: nil)
            }
            
        })
        
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

extension EmailVerificationController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        loadingIndicator.startAnimating()
        scheduledTimerWithTimeInterval()
        controller.dismiss(animated: true, completion: nil)
//        checkForVerification()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(showVerify), userInfo: nil, repeats: true)
    }
    
}
