//
//  WelcomeController.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 1/27/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Pastel
import FacebookLogin
import FacebookCore
import FirebaseAuth
import FirebaseFirestore
import PopupDialog
import Crashlytics

class WelcomeController: UIViewController {
    
    struct MyProfileRequest: GraphRequestProtocol {
        struct Response: GraphResponseProtocol {
            init(rawResponse: Any?) {
                // Decode JSON from rawResponse into other properties here.
//                print("Raw Response", rawResponse)
            }
        }
        
        var graphPath = "/me"
        var parameters: [String : Any]? = ["fields": "id, name, firstName"]
        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = .defaultVersion
    }
    
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
    
    var loginButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(named: "Already Have Account")?.withRenderingMode(.alwaysOriginal), for: .normal)
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
        
        //Login Button
        view.addSubview(loginButton)
        loginButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 25, paddingRight: 0, width: 296, height: 41)
        loginButton.centerHoriziontally(in: view)
        loginButton.addTarget(self, action: #selector(loginClicked), for: .touchUpInside)
        
        //Email Btn
        view.addSubview(emailButton)
        emailButton.anchor(top: nil, left: nil, bottom: loginButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 296, height: 41)
        emailButton.centerHoriziontally(in: view)
        
        //Facebook Btn
        view.addSubview(fbButton)
        fbButton.anchor(top: nil, left: nil, bottom: emailButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 18, paddingRight: 0, width: 296, height: 41)
        fbButton.centerHoriziontally(in: view)
        fbButton.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
        
        //Logo
        view.addSubview(foggyGlassesLogo)
        foggyGlassesLogo.anchor(top: foggyGlassesTitle.bottomAnchor, left: view.leftAnchor, bottom: fbButton.topAnchor, right: view.rightAnchor, paddingTop: 35, paddingLeft: 35, paddingBottom: 35, paddingRight: 35, width: 0, height: 0)
        foggyGlassesLogo.logoAnimate(animation: .scale)
    }
    
    
    @objc func facebookLogin() {
//        Crashlytics.sharedInstance().crash()
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (result) in
            switch result {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_ ,_ , _):
               self.logInWithFirebaseFromFacebook()
            }
        }
    }
    
    func logInWithFirebaseFromFacebook() {
        if let authToken = AccessToken.current?.authenticationToken {
            let credential = FacebookAuthProvider.credential(withAccessToken: authToken)
            Auth.auth().signInAndRetrieveData(with: credential) { (result, err) in
                if let err = err {
                    print("err", err)
                    return
                }
                if let uid = result?.user.uid {
                    self.getFbId(completion: { (data) in
                        if let data = data {
                            let firstNameFB = data["first_name"] as? String
                            let lastNameFB = data["last_name"] as? String
                            let email = data["email"] as? String
                            self.updateUserEmailFromFB(email: email)
                            self.checkIfUserExists(uid: uid,firstName: firstNameFB, lastName: lastNameFB, email: email)
                        } else {
                            self.displayError(title: "Facebook Account Error", error: "Error signing in with Facebook")
                        }
                    })
                }
            }
        }
    }
    
    private func checkIfUserExists(uid: String, firstName: String?, lastName: String?, email: String?) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snap, err) in
            if let err = err {
                print("User err", err)
                return
            }
            if let snap = snap {
                print("Exists", snap.exists.description)
                if snap.exists {
                    PhoneVerificationManager.shared.isPhoneVerified(uid: uid, completion: { (verified) in
                        if verified {
                            self.showFeed()
                        } else {
                            self.showValidate()
                        }
                    })
                    
                } else {
                    self.showUsernameCreate(firstName: firstName, lastName: lastName)
                }
            }
        }
    }
    
    func showValidate() {
        let valid = EmailVerificationController()
        let nav = UINavigationController(rootViewController: valid)
        present(nav, animated: true, completion: nil)
    }
    
    
    private func updateUserEmailFromFB(email:String?) {
        guard let email = email else { return }
        
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (err) in
            if let err = err {
                print("error", err)
                
            }
            print("COmpleted update email")
        })
        
    }
    
    private func showUsernameCreate(firstName: String?, lastName:String?) {
        let join = FBUsernameController()
        join.firstName = firstName
        join.lastName = lastName
        let nav = UINavigationController(rootViewController: join)
        present(nav, animated: true, completion: nil)
    }
    
    private func showFeed() {
        let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let nav = UINavigationController(rootViewController: feed)
        present(nav, animated: true, completion: nil)
    }
    
    @objc func continueWithEmail() {
        
        let signUp = SignUpController()
        navigationController?.pushViewController(signUp, animated: true)
    }
    
    ///Transitions to Login Controller
    @objc func loginClicked() {
        let login = LoginController()
        navigationController?.pushViewController(login, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func getFbId(completion: @escaping([String: Any]?)->()){
        if(AccessToken.current != nil){
            let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture, birthday"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
            req.start({ (connection, result) in
                switch result {
                case .failed(let error):
                    print(error)
                    completion(nil)
                    
                case .success(let graphResponse):
                    if let responseDictionary = graphResponse.dictionaryValue {
                        completion(responseDictionary)
//                        print(responseDictionary)
//                        let firstNameFB = responseDictionary["first_name"] as? String
//                        let lastNameFB = responseDictionary["last_name"] as? String
//                        let socialIdFB = responseDictionary["id"] as? String
//                        let genderFB = responseDictionary["gender"] as? String
//                        let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
//                        let photoData = pictureUrlFB!["data"] as? [String:Any]
//                        let photoUrl = photoData!["url"] as? String
//                        print(firstNameFB, lastNameFB, socialIdFB, genderFB, photoUrl)
                    }
                }
            })
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

