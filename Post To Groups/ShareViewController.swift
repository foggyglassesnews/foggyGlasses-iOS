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
    var url: URL? {
        didSet {
            guard let url = url?.absoluteString else {
                logErrorAndCompleteRequest(error: nil)
                return
            }
            
            FirebaseManager.global.swiftGetArticle(link: url) { (response) in
                self.articleResponse = response
            }
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

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        
        checkUserStatus()
        setupUI()
        getUrl()
    }
    
    ///Gets current user, check shared group for UID, if it matches Auth.currentUser then get Groups
    ///If UID != Auth.currentUser go to keychain, get credentials for UID, reautheticate with Fierbase ****
    ///Reautheticate with firebase not implemented since it seems Firebase is storing auth token in keychain already
    private func checkUserStatus() {
        
        ///Get UID from shared group, if none then they signed out
        guard let sharedFirebaseUid = UserDefaults.init(suiteName: sharedGroup)?.string(forKey: "Firebase User Id") else {
            print("No shared user Id, signing out and closing")
            do {
                try? Auth.auth().signOut()
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
            return
        }
        
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            
            //This should never actually get called
            if sharedFirebaseUid != uid {
                print("Shared Firebase ID does not match current UID, signing out and closing")
                do {
                    try? Auth.auth().signOut()
                    self.getFromKeychain(uid: sharedFirebaseUid)
                }
                return
            }
            
            //Get Groups
            let shared = UserDefaults.init(suiteName: "group.posttogroups.foggyglassesnews.com")
            if let groupNames = shared?.dictionary(forKey: "GroupNames-"+uid) as? [String: String] {
                self.userGroups = groupNames
            }
            
            if let groupUsers = shared?.dictionary(forKey: "GroupUsers-"+uid) as? [String: [String]] {
                self.groupUsers = groupUsers
            }
            
//            FirebaseManager.global.getGroups(uid: uid) { (groupData) in
//                if let dictionary = groupData {
//                    if let groups = dictionary["groups"] {
//                        self.userGroups = groups
//                    }
//                }
//            }
        } else {
            //This should never actually get called
            print("No current user")
            self.getFromKeychain(uid: sharedFirebaseUid)
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
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
//                    if let uid = Auth.auth().currentUser?.uid, let url = results.value(forKey: "URL") as? String {
//                        //                            let parameters = [
//                        //                                "url": results.value(forKey: "URL") as? String,
//                        //                                "comment": self.contentText,
//                        //                                "title": self.pageTitle ?? "",
//                        //                                "quote": results.value(forKey: "selectedText") as? String
//                        //                                ] as? [String: String]
//                        //
//                        FirebaseManager.global.swiftGetArticle(link: url) { (response) in
//                            if let response = response {
//                                let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: response.title ?? "", response: response)
////                                let articleData: [String: Any] = ["title":response.title ?? "",
////                                                                  "url":response.finalUrl?.absoluteString,
////                                                                  "description": response.description ?? "",
////                                                                  "imageUrlString": response.image ?? "",
////                                                                  "shareUserId":Auth.auth().currentUser?.uid ?? ""
////                                ]
//
//                                let article = Article(id: "localArticle", data: articleData)
//
//
//
//                                FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
//                                    if success {
//                                        if self.saveArticle {
//                                            FirebaseManager.global.saveArticle(uid: uid, articleId: articleId!, completion: { (success) in
//                                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                                            })
//                                        } else {
//                                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                                        }
//
//                                    } else {
//                                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                                    }
//                                }
//                            } else {
//                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                            }
//                        }
//
//                    } else {
//                        self.logErrorAndCompleteRequest(error: nil)
//                    }
                    
                    
                })
            }
        }
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    

    
    override func didSelectPost() {
        guard let url = url?.absoluteString else {
            logErrorAndCompleteRequest(error: nil)
            return
        }
        if let response = articleResponse {
            if let uid = Auth.auth().currentUser?.uid {
                let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: nil, response: response)
                let article = Article(id: "localArticle", data: articleData)
                
                var generatedGroups = [FoggyGroup]()
                for i in self.selectedGroups {
                    let members = self.groupUsers[i] ?? []
                    let g = FoggyGroup(id: i, data: ["members":members])
                    generatedGroups.append(g)
                }
                
                FirebaseManager.global.sendArticleToGroups(article: article, groups: generatedGroups, comment: nil) { (success, articleId) in
                    if success {
                        if self.saveArticle {
                            FirebaseManager.global.saveArticle(uid: uid, articleId: articleId!, completion: { (success) in
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        } else {
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        
                    } else {
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    }
                }
            }
            return
        } else if let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.swiftGetArticle(link: url) { (response) in
            if let response = response {
                let articleData = FirebaseManager.global.convertResponseToFirebaseData(articleText: nil, response: response)
                let article = Article(id: "localArticle", data: articleData)
                
                var generatedGroups = [FoggyGroup]()
                for i in self.selectedGroups {
                    let members = self.groupUsers[i] ?? []
                    let g = FoggyGroup(id: i, data: ["members":members])
                    generatedGroups.append(g)
                }
                
                FirebaseManager.global.sendArticleToGroups(article: article, groups: generatedGroups, comment: nil) { (success, articleId) in
                    if success {
                        if self.saveArticle {
                            FirebaseManager.global.saveArticle(uid: uid, articleId: articleId!, completion: { (success) in
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        } else {
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        
                    } else {
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    }
                }
            } else {
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    } else {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    ///Open Foggy Glasses App
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
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
                self.pushConfigurationViewController(vc)
            }
            return [groups]
        }
        return []
    }
    
    func openFG() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        let selectedUrl = self.url ?? URL(string: "")!
        if let url = URL(string: "createGroup://createGroup?link=\(selectedUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"){
            if openURL(url) {
                print("Opened URL")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                print("Error opening URL")
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func getFromKeychain(uid: String) {
        if Auth.auth().currentUser == nil {
            
            let query: [String: Any] =
                [ kSecClass as String:           kSecClassGenericPassword
                    , kSecAttrGeneric as String:     uid
                    , kSecAttrAccessGroup as String: "9UGK7H99PS.com.FoggyGlassesNews.FG"
                    , kSecReturnAttributes as String: true
                    , kSecReturnData as String:       true
            ]
            
            enum KeychainError: Error {
                case noPassword
                case unexpectedPasswordData
                case unhandledError(status: OSStatus)
            }
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            //            guard status != errSecItemNotFound
            //                else { throw KeychainError.noPassword }
            //            guard status == errSecSuccess
            //                else { throw KeychainError.unhandledError(status: status) }
            print("\n\n\(status)\n\n")
            
            //            guard
            let existingItem = item as! [String : Any]
            let passwordData = existingItem[kSecValueData as String] as! Data
            let password = String(data: passwordData, encoding: String.Encoding.utf8)!
            let account = existingItem[kSecAttrAccount as String] as! String
            
            //            print("\n\n\(account)\n\n")
            //            print("\n\n\(password)\n\n")
            
        }
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
