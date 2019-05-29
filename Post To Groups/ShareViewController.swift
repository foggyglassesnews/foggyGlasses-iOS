//
//  ShareViewController.swift
//  Post To Groups
//
//  Created by Ryan Temple on 3/7/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import SwiftLinkPreview
import Firebase
//import Firebase

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

class ShareViewController: SLComposeServiceViewController {
    
    ///URL from article
    var isLoading = false
    var url: URL? {
        didSet {
            print("Set URL", url)
            if !isLoading{
                isLoading = true
                guard let url = url?.absoluteString else {
                    logErrorAndCompleteRequest(error: nil)
                    self.isLoading = false
                    return
                }
                
                FirebaseManager.global.swiftGetArticle(link: url, completion: { (response) in
                    self.articleResponse = response
                    self.isLoading = false
                }, shareExtension: true)
            }
            
            
//            FirebaseManager.global.swiftGetArticle(link: url) { (response) in
//                self.articleResponse = response
//            }
        }
    }
    
    ///Response we get after setting the URL.
    var articleResponse: Response?
    
    ///Default Item title on launch
    var selectedValue = "Saved Articles"
    
    ///Dictionary that stores [GroupId: Name], used for looking up name for specific group id
    var userGroups = [String: String]()
    ///Dictionary that stores [GroupId:[UserId]], used for looking up group userIds from GroupId
    var groupUsers = [String: [String]]()
    ///Array of selected Group Ids
    var selectedGroups = [String]()
    ///Bool determining if we should save article too
    var saveArticle = true
    
    override func beginRequest(with context: NSExtensionContext) {
        super.beginRequest(with: context)
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        print("IS content valid")
        return true
    }
    
    var context: NSExtensionContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let app = FirebaseApp.app() {
            
        } else {
            FirebaseApp.configure()
        }
        
        
        checkUserStatus()
        setupUI()
        getUrl()
        
//        context = extensionContext
    }
    
    ///Gets current user, check shared group for UID, if it matches Auth.currentUser then get Groups
    ///If UID != Auth.currentUser go to keychain, get credentials for UID, reautheticate with Fierbase ****
    ///Reautheticate with firebase not implemented since it seems Firebase is storing auth token in keychain already
    private func checkUserStatus() {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        ///Get UID from shared group, if none then they signed out
        guard let sharedFirebaseUid = UserDefaults.init(suiteName: sharedGroup)?.string(forKey: "Firebase User Id") else {
            print("No shared user Id, signing out and closing")
            do {
                try? Auth.auth().signOut()
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
            return
        }
        print("SharedId", sharedFirebaseUid)
        
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            print(uid)
            if sharedFirebaseUid != uid {
                print("Not the same signing out and back in")
                do {
                    try? Auth.auth().signOut()
                    self.signInGetGroups(sharedFirebaseUid: sharedFirebaseUid)
                }
            } else {
                if let groupNames = shared?.dictionary(forKey: "GroupNames-"+uid) as? [String: String] {
                    self.userGroups = groupNames
                }
                
                if let groupUsers = shared?.dictionary(forKey: "GroupUsers-"+uid) as? [String: [String]] {
                    self.groupUsers = groupUsers
                }
            }
            //Get Groups
            
            
            
        } else {
            signInGetGroups(sharedFirebaseUid: sharedFirebaseUid)
        }
    }
    
    func signInGetGroups(sharedFirebaseUid: String) {
        let shared = UserDefaults.init(suiteName: sharedGroup)
        if let groupNames = shared?.dictionary(forKey: "GroupNames-"+sharedFirebaseUid) as? [String: String] {
            self.userGroups = groupNames
        }
        
        if let groupUsers = shared?.dictionary(forKey: "GroupUsers-"+sharedFirebaseUid) as? [String: [String]] {
            self.groupUsers = groupUsers
        }
        
        if let facebook = shared?.bool(forKey: "Facebook-"+sharedFirebaseUid) {
            print("Got Facebook", facebook)
            if facebook {
                if let token = shared?.string(forKey: "FBToken-"+sharedFirebaseUid) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: token)
                    Auth.auth().signInAndRetrieveData(with: credential) { (result, err) in
                        if let err = err {
                            print("err", err)
                            return
                        }
                        
                        print("Successfully signed in facebook ")
                        
                    }
                }
            } else {
                if let email = shared?.string(forKey: "Email-"+sharedFirebaseUid), let pass = shared?.string(forKey: "Pass-"+sharedFirebaseUid) {
                    print("Got email and pword", email, pass)
                    Auth.auth().signIn(withEmail: email, password: pass) { (result, err) in
                        if let err = err {
                            print("Err", err)
                            return
                        }
                        print("Successfully signed in with email")
                    }
                }
            }
        }
        
    }
    
    private func setupUI() {
        configNavigationBar()
        let imageView = UIImageView(image: UIImage(named: "Side Logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem?.title = "Send"
    }
    
    ///Responsible for grabbing URL
    private func getUrl() {
        print("Count", extensionContext?.inputItems.count)
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        guard let attachments = extensionItem.attachments else { return }
        for attachment in attachments {
            print("Attachment", attachment)
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil) { (results, error) in
                    self.url = results as! URL?
                }
            }
            else if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                    if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                    guard let dictionary = decoder as? NSDictionary else {
                        self.logErrorAndCompleteRequest(error: error); return }
                    guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                        self.logErrorAndCompleteRequest(error: error); return }
                    self.url = URL(string: results.value(forKey: "URL") as? String ?? "")
                    return
                })
            }
        }
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectPost() {
        
        guard let response = articleResponse, let uid = Auth.auth().currentUser?.uid else {
            //No response!!!
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        
        let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: nil, response: response)
        let article = Article(id: "localArticle", data: articleData)
        
        var generatedGroups = [FoggyGroup]()
        for i in self.selectedGroups {
            let members = self.groupUsers[i] ?? []
            let g = FoggyGroup(id: i, data: ["members":members])
            generatedGroups.append(g)
        }
        
        if self.saveArticle {
            FirebaseManager.global.uploadArticle(article: article) { (success, aid) in
                if success {
                    FirebaseManager.global.saveArticle(uid: uid, articleId: aid!) { (success) in
                        if generatedGroups.isEmpty {
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        
                        
                    }
                }
                
            }
            
        }
        
        if !generatedGroups.isEmpty {
            FirebaseManager.global.sendArticleToGroups(article: article, groups: generatedGroups, comment: nil) { (success, articleId) in
                if success {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    
                } else {
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        }
        
    }
    
    ///Open Foggy Glasses App
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
//                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil  )
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        if let groups = SLComposeSheetConfigurationItem() {
            groups.title = "Choose Group(s)"
            groups.value = selectedValue
            groups.tapHandler = {
                let vc  = ShareSelectViewController()
                vc.groups = self.userGroups
                vc.delegate = self
                vc.context = self.extensionContext
                vc.url = self.url
                self.pushConfigurationViewController(vc)
            }
            return [groups]
        }
        return []
    }
    
    func openFG() {
//        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        let selectedUrl = self.url ?? URL(string: "")!
        if let url = URL(string: "createGroup://createGroup?link=\(selectedUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"){
            if openURL(url) {
                print("Opened URL")
                //Intentionally crashing
//                var x: UIView!
//                x.removeFromSuperview()
//                self.context!.completeRequest(returningItems: [], completionHandler: nil)
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                print("Error opening URL")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

}

extension ShareViewController: GroupSelectProtocol {
    func selected(groups: [String], save: Bool) {
        print("Selected groups:", groups)
        selectedGroups = groups
        self.saveArticle = save
        if groups.count == 0 {
            
            if save {
                selectedValue = "Saved Articles"
            } else {
                selectedValue = ""
            }
            
        } else if groups.count == 1 {
            if let first = groups.first {
                if save {
                    selectedValue = userGroups[first] ?? "" + ""
                } else {
                    selectedValue = userGroups[first] ?? ""
                }
                
            }
        } else {
            if save {
                selectedValue = "\(groups.count + 1) Groups"
            } else {
                selectedValue = "\(groups.count) Groups"
            }
            
        }
        reloadConfigurationItems()
        popConfigurationViewController()
    }
    
    func selectedNewGroup() {
        print("Opening FG")
        openFG()
    }
   
}
