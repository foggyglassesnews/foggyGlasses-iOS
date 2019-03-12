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
import Firebase
//import Firebase

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

class ShareViewController: SLComposeServiceViewController {
    
    ///URL from article
    var url: URL?
    
    ///Config Item Title
    var selectedValue = ""
    
    var userGroups = [FoggyGroup]()
    var selectedGroups = [FoggyGroup]()
    
    var saveArticle = false

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            
            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                if let shareURL = url as? URL {
                    // do what you want to do with shareURL
                    print("Share URL:", shareURL)
                    self.url = shareURL
                }
            }
        }
        return true
    }
    
    func flow(uid: String) {
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
            
                        print("\n\n\(account)\n\n")
                        print("\n\n\(password)\n\n")
            return
            //                else {
            //                    throw KeychainError.unexpectedPasswordData
            //            }
            //            let credentials = Credentials(username: account, password: password)
            Auth.auth().signIn(withEmail: account, password: password) {
                (user, error) in
                
                /* If sign-in is not successful, show log in screen
                 TODO: show error text
                 Otherwise do nothing, and let the nvc load the default
                 root controller.
                 */
                if error != nil {
                    print("\n\n\(error!.localizedDescription)\n\n")
//                    CommonDefaults.showLogin(navController: self)
                } else {
                    print("\n\nyay?\n\n")
                }
            }
        }
        
//        if CommonDefaults.isUserLoggedIn() == false {
//            CommonDefaults.showLogin(navController: self)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()
        
        guard let sharedFirebaseUid = UserDefaults.init(suiteName: sharedGroup)?.string(forKey: "Firebase User Id") else {
            print("No shared user Id, signing out and closing")
            do {
                try? Auth.auth().signOut()
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
            return
        }
        print("Shared UID", sharedFirebaseUid)

        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            print("Current User ID", uid)
            if sharedFirebaseUid != uid {
                print("Shared Firebase ID does not match current UID, signing out and closing")
                do {
                    try? Auth.auth().signOut()
                    self.flow(uid: sharedFirebaseUid)
//                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                return
            }
            FirebaseManager.global.getGroups(uid: uid) { (groupData) in
                if let dictionary = groupData {
                    if let groups = dictionary["groups"] {
                        self.userGroups = groups
                    }
                }
            }
        } else {
            print("No current user")
            self.flow(uid: sharedFirebaseUid)
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        
        setupUI()
        getUrl()
    }
    
    func setupUI() {
        configNavigationBar()
        let imageView = UIImageView(image: UIImage(named: "Side Logo"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        navigationController?.navigationBar.topItem?.titleView = imageView
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem?.title = "Send"
    }
    
    func getUrl() {
        
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = kUTTypeURL as String
        let contentTypeText = kUTTypeText as String
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            print("Attachment", attachment)
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil) { (results, error) in
                    self.url = results as! URL?
                }
            }
//            attac
//            if attachment.isURL {
//                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
//                    let url = results as! URL?
//                    self.urlString = url!.absoluteString
//                })
//            }
//            if attachment.isText {
//                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
//                    let text = results as! String
//                    self.textString = text
//                    _ = self.isContentValid()
//                })
//            }
        }
        
        return
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                if let shareURL = url as? URL {
                    // do what you want to do with shareURL
                    print("Share URL:", shareURL)
                    self.url = shareURL
                }
//                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
            }
        }
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func newSelectPost() {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
        if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
        let parameters = ["caption": self.contentText.trimmingCharacters(in: .whitespacesAndNewlines)]
        for item in items {
            guard let attachments = item.attachments else { continue }
            for attachment in attachments {
               if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                        guard let dictionary = decoder as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        if let uid = Auth.auth().currentUser?.uid, let url = results.value(forKey: "URL") as? String {
//                            let parameters = [
//                                "url": results.value(forKey: "URL") as? String,
//                                "comment": self.contentText,
//                                "title": self.pageTitle ?? "",
//                                "quote": results.value(forKey: "selectedText") as? String
//                                ] as? [String: String]
//
                            FirebaseManager.global.swiftGetArticle(link: url) { (response) in
                                if let response = response {
                                    let articleData: [String: Any] = ["title":response.title ?? "",
                                                                      "url":response.finalUrl?.absoluteString,
                                                                      "description": response.description ?? "",
                                                                      "imageUrlString": response.image ?? "",
                                                                      "shareUserId":Auth.auth().currentUser?.uid ?? ""
                                    ]
                                    
                                    let article = Article(id: "localArticle", data: articleData)
                                    
                                    
                                    
                                    FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
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
                            self.logErrorAndCompleteRequest(error: nil)
                        }
                        
                        
                    })
                }
               else if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                
                attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                    if let url = url as? URL {
                        // do what you want to do with shareURL
                        print("Share URL:", url)
                        if let uid = Auth.auth().currentUser?.uid {
                            FirebaseManager.global.swiftGetArticle(link: url.absoluteString) { (response) in
                                if let response = response {
                                    let articleData: [String: Any] = ["title":response.title ?? "",
                                                                      "url":response.finalUrl?.absoluteString,
                                                                      "description": response.description ?? "",
                                                                      "imageUrlString": response.image ?? "",
                                                                      "shareUserId":Auth.auth().currentUser?.uid ?? ""
                                    ]
                                    
                                    let article = Article(id: "localArticle", data: articleData)
                                    
                                    
                                    
                                    FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
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
                }
               }
               
               else {
                    self.logErrorAndCompleteRequest(error: nil)
                }
            }
        }
    }
    
    func firebaseSend() {
        guard let url = url?.absoluteString else {
            logErrorAndCompleteRequest(error: nil)
            return
        }
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseManager.global.swiftGetArticle(link: url) { (response) in
                if let response = response {
                    let articleData: [String: Any] = ["title":response.title ?? "",
                                                      "url":response.finalUrl?.absoluteString,
                                                      "description": response.description ?? "",
                                                      "imageUrlString": response.image ?? "",
                                                      "shareUserId":Auth.auth().currentUser?.uid ?? ""
                    ]
                    
                    let article = Article(id: "localArticle", data: articleData)
                    
                    
                    
                    FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
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
    

    override func didSelectPost() {
        firebaseSend()
        return
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//        newSelectPost()
//        return
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for it in inputItems {
            if let attachments = it.attachments {
                for attachment in attachments {
                    if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                        attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                            if let url = url as? URL {
                                // do what you want to do with shareURL
                                print("Share URL:", url)
                                if let uid = Auth.auth().currentUser?.uid {
                                    FirebaseManager.global.swiftGetArticle(link: url.absoluteString) { (response) in
                                        if let response = response {
                                            let articleData: [String: Any] = ["title":response.title ?? "",
                                                                              "url":response.finalUrl?.absoluteString,
                                                                              "description": response.description ?? "",
                                                                              "imageUrlString": response.image ?? "",
                                                                              "shareUserId":Auth.auth().currentUser?.uid ?? ""
                                            ]
                                            
                                            let article = Article(id: "localArticle", data: articleData)
                                            
                                            
                                            
                                            FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
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
                        }
                    } else {
                        logErrorAndCompleteRequest(error: nil)
                    }
                }
            }
        }
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first,
            itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {

            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, error) in
                if let url = url as? URL {
                    // do what you want to do with shareURL
                    print("Share URL:", url)
                    if let uid = Auth.auth().currentUser?.uid {
                        FirebaseManager.global.swiftGetArticle(link: url.absoluteString) { (response) in
                            if let response = response {
                                let articleData: [String: Any] = ["title":response.title ?? "",
                                                                  "url":response.finalUrl?.absoluteString,
                                                                  "description": response.description ?? "",
                                                                  "imageUrlString": response.image ?? "",
                                                                  "shareUserId":Auth.auth().currentUser?.uid ?? ""
                                ]

                                let article = Article(id: "localArticle", data: articleData)



                                FirebaseManager.global.sendArticleToGroups(article: article, groups: self.selectedGroups) { (success, articleId) in
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
            }
        }
        else {
            print("Ooops")
        }
        
        
//        print(extensionContext?.inputItems)
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
//            if let itemProvider = item.attachments?.first {
//                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
//                        if let shareURL = url as? NSURL {
//                            // send url to server to share the link
//                            print("SHARE URL")
//                        }
////                        self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
//                    })
//                }
//            }
//        }
        
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
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
        guard let selectedUrl = self.url else {
            print("No URL")
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            return
        }
        if let url = URL(string: "createGroup://createGroup?link=\(selectedUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"){
            if openURL(url) {
                print("Opened URL")
            } else {
                print("Error opening URL")
                
            }
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
}

extension ShareViewController: GroupSelectProtocol {
    func selected(groups: [FoggyGroup], save: Bool) {
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
                    selectedValue = first.name + ""
                } else {
                    selectedValue = first.name
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
        openFG()
    }
   
}
