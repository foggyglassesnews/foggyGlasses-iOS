//
//  WelcomeController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 1/27/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import SwiftLinkPreview
import Pastel

class WelcomeController: UIViewController {
    
    //MARK: UI Elements
    var bg: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(named: "Welcome BG")
        return v
    }()
    
    var foggyGlassesTitle: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "Foggy Glasses Title")
        return v
    }()
    
    var foggyGlassesLogo: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.image = UIImage(named: "Foggy Logo")
        return v
    }()
    
    var emailButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Email Btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    var fbButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "FB Btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        v.contentMode = .scaleAspectFit
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configPastelGradient()
        configUI()
        
        emailButton.addTarget(self, action: #selector(continueWithEmail), for: .touchUpInside)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func configPastelGradient() {
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .top
        pastelView.endPastelPoint = .bottom
        
        // Custom Duration
        pastelView.animationDuration = 5
        
        // Custom Color
        pastelView.setColors([.foggyBlue, .foggyGrey])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
    }
    
    private func configUI() {
        //BG
        view.addSubview(bg)
        bg.pin(in: view)
        
        //Title
        view.addSubview(foggyGlassesTitle)
        foggyGlassesTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 194, height: 51)
        foggyGlassesTitle.centerHoriziontally(in: view)
        
        //Line
//        let line = UIView()
//        line.backgroundColor = UIColor(red:0.44, green:0.44, blue:0.44, alpha:1.0)
//        view.addSubview(line)
//        line.anchor(top: foggyGlassesTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 1)
        
        //Email Btn
        view.addSubview(emailButton)
        emailButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 296, height: 41)
        emailButton.centerHoriziontally(in: view)
        
        //Facebook Btn
        view.addSubview(fbButton)
        fbButton.anchor(top: nil, left: nil, bottom: emailButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 296, height: 41)
        fbButton.centerHoriziontally(in: view)
        
        //Logo
        view.addSubview(foggyGlassesLogo)
        foggyGlassesLogo.anchor(top: foggyGlassesTitle.bottomAnchor, left: view.leftAnchor, bottom: fbButton.topAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    }
    
    @objc func continueWithEmail() {
        
        let signUp = SignUpController()
        navigationController?.pushViewController(signUp, animated: true)
    }
    
    func getArticle() {
        let link = "https://www.washingtonpost.com/technology/2019/01/31/this-wasnt-how-internet-was-meant-be-net-neutrality-advocates-prepare-face-fcc-court/?utm_term=.2eb49003b3bc"
        let s = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
        s.preview(link, onSuccess: { (response) in
            print("Success!", response)
        }) { (err) in
            print("Error!", err)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    } 

}

