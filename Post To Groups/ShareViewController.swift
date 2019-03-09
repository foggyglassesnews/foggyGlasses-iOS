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
//import Firebase

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

class ShareViewController: SLComposeServiceViewController {
    
    var url: URL?
    
    var groupIds = [String]()
    var groupNames = [String]()
    
    var selectedValue = ""

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        print("Extension Content Input Items:", extensionContext?.inputItems)
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
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getUrl()
        let defaults = UserDefaults.init(suiteName: sharedGroup)
        if let groupNames = defaults?.array(forKey: "Group Names") as? [String], let groupIds = defaults?.array(forKey: "Group Ids") as? [String] {
            self.groupNames = groupNames
            self.groupIds = groupIds
        }
        
        
        
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
        
        

    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
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
                vc.ids = self.groupIds
                vc.names = self.groupNames
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
    func selected(groups: [String]) {
        print("Selected groups:", groups)
        if groups.count == 0 {
            selectedValue = ""
        } else if groups.count == 1 {
            let returnIdx = returnIdxOfId(id: groups.first!)
            selectedValue = groupNames[returnIdx]
        } else {
            selectedValue = "\(groups.count) Groups"
        }
        reloadConfigurationItems()
        popConfigurationViewController()
    }
    
    func selectedNewGroup() {
        openFG()
    }
    
    func returnIdxOfId(id:String)->Int {
        var counter = 0
        for groupId in groupIds {
            if groupId == id {
                return counter
            } else {
                counter += 1
            }
        }
        return counter
    }
    
}
