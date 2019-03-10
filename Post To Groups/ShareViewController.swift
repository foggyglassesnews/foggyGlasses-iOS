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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseApp.configure()

        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            FirebaseManager.global.getGroups(uid: uid) { (groupData) in
                if let dictionary = groupData {
                    if let groups = dictionary["groups"] {
                        self.userGroups = groups
                    }
                }
            }
        } else {
            print("No current user")
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

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        if let uid = Auth.auth().currentUser?.uid, let url = self.url {
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
//                            if self.saveArticle {
//                                FirebaseManager.global.saveArticle(uid: uid, articleId: articleId!, completion: { (success) in
//                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                                })
//                            } else {
//                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//                            }
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

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
