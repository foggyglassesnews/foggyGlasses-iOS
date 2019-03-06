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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        title = "Verification"
        view.backgroundColor = .feedBackground
        
        view.addSubview(logo)
        logo.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 32, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 145)
        logo.centerHoriziontally(in: view)
        
        view.addSubview(text)
        text.anchor(top: logo.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 109)
        
        for i in [logo, text] {
            i.contentMode = .scaleAspectFit
        }
        
        view.addSubview(button)
        button.anchor(top: text.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 32, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 188, height: 50)
        button.centerHoriziontally(in: view)
        button.setImage(UIImage(named: "Verification Button")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(sendEmailVerificationAgain), for: .touchUpInside)
        
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
//                let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
//                let nav = UINavigationController(rootViewController: feed)
//                present(nav, animated: true, completion: nil)
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
